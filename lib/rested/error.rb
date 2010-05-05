
module Rested
    
    class Error < ::Exception
        
        attr_accessor :status, :reason, :http_response, :message
        
        def initialize(res)

            hash = Rested::Base.decode_response(res)
            if hash.include? "error" then
                self.message = hash["error"]
            end
            self.status = res.status
            self.reason = res.reason
            self.http_response = res
            
        end
        
        def to_s
            "#{self.status} #{self.reason}" + (self.message.nil? ? "" : ": #{self.message}")
        end
        
        # def self.handle(res)
        #   case res.status
        #       when 400
        #           raise "Bad request"
        #       when 401
        #           raise "401 Unauthorized"
        #       when 403
        #           raise "403 Forbidden"
        #       when 404
        #           raise "404 Not Found"
        #       when 405
        #           raise "405 Method Not Allowed"
        #       else
        #           raise "#{res.status} #{res.reason}" if res.status >= 400
        #   end 
        # end
        
    end
    
    class ObjectNotFound < Error
        attr_accessor :id
        
        def initialize(res)
            super(res)
            self.id = $1 if res.content =~ /Invalid Object.*?(\d+)/
        end
        
        def to_s
            "Invalid Object ID '#{self.id}'"
        end
    end
    
end