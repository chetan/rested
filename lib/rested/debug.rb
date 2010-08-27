module Rested
    
    @debug = false
    
    def self.debug(val=nil)
        return @debug unless val
        if val == true || val == 1 || val.nil? then
            @debug = STDOUT
        else
            @debug = val
        end
    end
    
    def self.debug=(val)
        self.debug(val)
    end

    def self.log(msg = nil, &block)
        return unless @debug
        if block_given? then
            s = yield
            return if not s.kind_of? String
            msg = s
        end
        return if msg.nil?
        if @debug.respond_to? :puts then
            @debug.puts(msg)
        elsif @debug.respond_to? :debug then
            @debug.debug(msg)
        else
            puts "[Rested.debug] #{msg}"
        end
    end
    
    def self.log_do(msg = nil, &block)
        if block_given? then
            s = yield
            return if not s.kind_of? String
            log { "* " + s }
        else
            log("* #{msg}")
        end
    end
    
    def self.log_in(msg = nil, &block)
        if block_given? then
            s = yield
            return if not s.kind_of? String
            log { "< " + s }
        else
            log("< #{msg}")
        end
    end
    
    def self.log_out(msg = nil, &block)
        if block_given? then
            s = yield
            return if not s.kind_of? String
            log { "> " + s }
        else
            log("> #{msg}")
        end
    end
    
end