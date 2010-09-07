require File.dirname(__FILE__) + '/ext'
require File.dirname(__FILE__) + '/base'

module Rested
  
  class Entity < Base

    rattr_accessor :endpoint, :id_field
    attr_accessor :errors
    Entity.id_field(:id)
    
    class << self

      attr_reader :before_filters, :after_filters

      def before_filters
        @before_filters ||= []
      end

      def after_filters
        @after_filters ||= []
      end

      def before_save(&block)
        before_filters << block
      end

      def after_save(&block)
        after_filters << block
      end
      
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
          add_field(f) unless fields.include? f 
        end
      end

      def delimited_fields
        @delimited_fields ||= {}
      end

      def delimited_field(field, delimiter = ',')
        unless fields.include? field
          delimited_fields[field] = delimiter
          add_field(field)
        end
      end

      def add_field(field)
        self.fields << field
        attr_accessor field
      end

      def find(id = nil, masquerade = nil)
        uri = self.endpoint
        uri += "/#{id}" if not id.nil?
        begin
          json = get(uri, :masquerade => masquerade)
        rescue Rested::Error => ex
          if ex.message =~ /Invalid/ then
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
      elsif file.is_a? Tempfile
        file = File.new(file.path)
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
      set_values(h) if h
      self.errors = []
    end

    def set_values(h)
      h.each_pair do |name, value|
        writer_method = "#{name}="
        value = parse_value(name, value)
        if respond_to?(writer_method)
          send(writer_method, value)
        else
          self[name.to_s] = value
        end
      end
    end

    def parse_value(name, value)
      if !value.nil? then
        if delimited_fields.include?(name.to_sym) then
          value = value.split(delimited_fields[name.to_sym]) if value.is_a?(String)
          value = value.map(&:to_i) if value.first.is_a?(String) && value.all?{ |v| v.to_i.to_s == v }
        else
          value = value.to_i if value.is_a?(String) && value.to_i.to_s == value
        end
        value
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

    def [](name)
      begin
        send(name)
      rescue NoMethodError
        nil
      end
    end

    def []=(name, value)
      begin
        send("#{name}=", value)
      rescue NoMethodError
        self.class.add_field(name)
        send("#{name}=", value)
      end
    end
    
    def to_h
      h = {}
      fields.each do |f|
        val = self.send(f)
        h[f] = val && delimited_fields.include?(f) ? val.join(delimited_fields[f]) : val
      end
      h
    end
    
    def to_json
      JSON.generate(to_h())
    end
    
    def to_s
      to_json()
    end

    def update_attributes(attributes = {})
      attributes.each_pair do |field, value|
        send("#{field}=", value)
      end
      save
    end

    def save
      begin
        save!
      rescue Rested::Error => e
        self.errors = e.validations
        false
      end
    end
    
    def save!(params = nil)
      self.class.before_filters.each do |f| 
        f.call(self) 
      end 
      
      uri = self.endpoint
      uri += "/#{self.id_val}" unless new?
      
      params = to_h() if not params
      params.delete(self.id_field) if new?
      
      if not self.files.empty?
        params.merge!(self.files)
        @files = {}
      end
      params = preserve_filenames(params)
      
      begin      
        ret = self.post(uri, params)
        cleanup_temp_files(params)
      rescue => ex
        cleanup_temp_files(params)
        raise ex
      end
      
      if new? then
        self.id_val = self.class.new(ret.values.first).id_val
      end
      self.class.after_filters.each do |f| 
        f.call(self) 
      end 
      true
    end
    
    def delete!
      return if new?
      uri = self.endpoint + "/#{self.id_val}"
      self.delete(uri)
      true
    end

    def fields
      @fields ||= self.class.fields
    end

    def delimited_fields
      @delimited_fields ||= self.class.delimited_fields
    end
    
    
    
    private
    
    # simple trick to force httpclient to pass the real filename
    # we simply rename our temp file to its original in a unique directory
    def preserve_filenames(params)
      params.each { |k,v|
        if v.kind_of? Tempfile and v.respond_to? "original_filename" then
          FileUtils.mkdir_p(v.path + "-origfile")
          FileUtils.mv(v.path, v.path + "-origfile/" + v.original_filename)
          params[k] = File.new(v.path + "-origfile/" + v.original_filename)
        end
      }
      params
    end
    
    # cleanup temp files created above
    def cleanup_temp_files(params)
      params.each { |k,v|
        if v.kind_of? File
          FileUtils.rm_rf([v.path, File.dirname(v.path)])
        end
      }
    end
    
  end
end
