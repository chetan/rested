
require File.dirname(__FILE__) + '/ext'
require File.dirname(__FILE__) + '/base'

module Rested
    
    class Entity < Base

        rattr_accessor :endpoint, :id_field
        Entity.id_field(:id)
        
        class << self
            
            def id_field
               @id_field ||= inherit_static_from_super(:id_field) || nil
            end
            
            def inherit_static_from_super(sym)
                if superclass.respond_to? sym then
                    val = superclass.send(sym)
                    return val if val.kind_of? Symbol
                    return val.dup if not val.nil?
                end
                return nil
            end
            
            def fields
                @fields ||= inherit_static_from_super(:fields) || []
            end
            
            def field(*args)
                args.each do |f|
                    if not fields.include? f then
                        self.fields << f
                        attr_accessor f
                    end
                end
            end

            def find(id = nil)
                uri = self.endpoint
                uri += "/#{id}" if not id.nil?
                begin
                    json = get(uri)
                rescue Rested::Error => ex
                    if ex.message =~ /Invalid Object/ then
                        raise ObjectNotFound.new(ex.http_response)
                    end
                end
                if id.nil? then
                    # return as list
                    return json.values.first.map { |j| new(j) }
                end
                return nil if json.values.empty?
                return new(json.values.first)
            end

            def list
                find()
            end

        end
        
        def files
            @files ||= {}
        end
        
        def add_file(name, file)
            if file.kind_of? String then
                raise IOError.new("File not found: #{file}") if not File.exists? file
                file = File.new(file)
            end
            return if not file.kind_of? File
            self.files[name] = file
        end
        
        def initialize(*args)
            if args.kind_of? Hash then
                h = args
            elsif args.kind_of? Array and args.first.kind_of? Hash then
                h = args.first
            end
            if not h.nil? then
                h.each_pair do |name, value|
                    writer_method = "#{name}="
                    if respond_to?(writer_method)
                        send(writer_method, value)
                    else
                        puts "setting #{name} = #{value}"
                        self[name.to_s] = value
                    end
                end
            end                 
        end
        
        def id_val
            self.send(id_field)
        end
        
        def id_val=(val)
            self.send("#{id_field.to_s}=", val)
        end
        
        def new_record?
            self.new?
        end

        def new?
            self.id_val.nil?
        end
        
        def to_h
            h = {}
            self.class.fields.each do |f|
                h[f] = self.send(f)
            end
            h
        end
        
        def to_json
            JSON.generate(to_h())
        end
        
        def to_s
            to_json()
        end
        
        def save!(params = nil)
            uri = self.endpoint
            uri += "/#{self.id_val}" if not new?
            params = to_h() if not params
            params.delete(self.id_field) if new?
            if not self.files.empty? then
                params.merge!(self.files)
                @files = {}
            end
            ret = self.post(uri, params)
            if new? then
                self.id_val = self.class.new(ret.values.first).id_val
            end
            true
        end
        
        def delete!
            return if new?
            uri = self.endpoint + "/#{self.id_val}"
            self.delete(uri)
            true
        end

    end
    
end