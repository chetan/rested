
# orginally cribbed from Rails edge. modified a bunch.

class Hash
  # By default, only instances of Hash itself are extractable.
  # Subclasses of Hash may implement this method and return
  # true to declare themselves as extractable. If a Hash
  # is extractable, Array#extract_options! pops it from
  # the Array when it is the last element of the Array.
  def extractable_options?
    instance_of?(Hash)
  end
end if not {}.respond_to? :extractable_options?

class Array
  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)           # => {}
  #   options(1, 2, :a => :b) # => {:a=>:b}
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end
end if not [].respond_to? :extract_options!

# Extends the class object with class and instance accessors for attributes,
# just like the native attr* accessors for instance attributes. Attributes can be 
# set at the class level and overriden at the instance level as well.
#
#  class Person
#    cattr_accessor :hair_colors
#  end
#
#  Person.hair_colors = [:brown, :black, :blonde, :red]
class Class
  def rattr_reader(*syms)
    options = syms.extract_options!
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        unless defined? @#{sym}
          @#{sym} = nil
        end

        def self.#{sym}(#{sym} = nil)
          return @#{sym} unless #{sym}
          @#{sym} = #{sym} 
        end
      EOS

      unless options[:instance_reader] == false
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          def #{sym}
              puts "reading instance opt #{sym} = " + @#{sym}
            return @#{sym} if @#{sym}
            puts "returning from class instead"
            self.class.#{sym}
          end
        EOS
      end
    end
  end

  def rattr_writer(*syms)
    options = syms.extract_options!
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        unless defined? @#{sym}
          @#{sym} = nil
        end

        def self.#{sym}=(obj)
          @#{sym} = obj
        end
      EOS

      unless options[:instance_writer] == false
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          def #{sym}=(obj)
              puts "setting instance opt to " + obj
            @#{sym} = obj
          end
        EOS
      end
      self.send("#{sym}=", yield) if block_given?
    end
  end

  def rattr_accessor(*syms, &blk)
    rattr_reader(*syms)
    rattr_writer(*syms, &blk)
  end
end if not Class.respond_to? :rattr_accessor
