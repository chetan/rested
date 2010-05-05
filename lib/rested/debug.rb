module Rested
    
    @debug = false
    
    def self.debug(val=nil)
        return @debug unless val
        if val == true then
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
            @debug.puts(s)
        elsif not msg.nil? then
            @debug.puts(msg)
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