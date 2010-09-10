
require 'rubygems'
require 'httpclient'
require 'json'

module Rested
    
    module BaseMethods
        
        # override this method to customize HTTPClient
        def setup_client
            @client = ::HTTPClient.new
            if self.user and self.pass then
                @client.set_auth(self.base_url, self.user, self.pass)
            end
            if not Rested.debug.nil?
                @client.debug_dev = (Rested.debug.respond_to?("<<") ? Rested.debug : STDOUT)
            end
            if Object.const_defined? "Rack" then
                handler = lambda { |path|
                    path =~ /(\..*?)$/
                    Rack::Mime.mime_type(($1.nil? ? nil : $1.downcase))
                }
                HTTP::Message.mime_type_handler = handler
            end
            @client
        end

        def client
            @client ||= setup_client()
        end
    
        def get(uri, params = nil)
            url = self.base_url + uri
            Rested.log_out{"GET #{url}"}
            Rested.log_out{"    params: " + params.inspect}
            handle_response(self.client.get(url, params))
        end
        
        def post(uri, params = nil)
            url = self.base_url + uri
            Rested.log_out{"POST #{url}"}
            Rested.log_out{"     params: " + params.inspect}
            handle_response(self.client.post(url, params))
        end
        
        def delete(uri)
            url = self.base_url + uri
            Rested.log_out{"DELETE #{url}"}
            res = self.client.delete(url)
            handle_error(res) if message.status >= 400
            return res.status == 200
        end

        def handle_response(message)
            handle_error(message) if message.status >= 400
            Rested.log_in{ puts; "HTTP/#{message.version} #{message.status} #{message.reason}"}
            Rested.log_in{ message.header.all.each{|h| Rested.log_in("#{h[0]}: #{h[1]}")}; puts }
            decode_response(message)
        end
        
        def decode_response(message)
            ct = message.contenttype
            if ct =~ /json|javascript/ then
                decode_json_response(message)
            elsif ct =~ /xml/ then
                decode_xml_response(message)
            else
                Rested.log_in { "\n" + message.content }
                raise "Unknown response type"
            end
        end
        
        def decode_json_response(message)
            begin
                JSON.load(message.content)
            rescue => ex
                nil
            end
        end
        
        def decode_xml_response(message)
            raise NotImplementedError # TODO
        end

        def handle_error(message)
            Rested.log_in{ puts; "HTTP/#{message.version} #{message.status} #{message.reason}"}
            Rested.log_in{ message.header.all.each{|h| Rested.log_in("#{h[0]}: #{h[1]}")}; puts }
            raise Rested::Error.new(message)
        end
        
    end
    
    class Base
    
        rattr_accessor :base_url, :user, :pass

        class << self
            include BaseMethods     
        end
        
        include BaseMethods
    
    end

end
