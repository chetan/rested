module Rested
  class Validations
    def initialize(validations_hash)
      self.validations_hash = validations_hash || {}
    end

    def full_messages
      validations_hash.inject([]) do |messages, validation|
        messages << "#{humanize(validation.first)} #{validation.last}"
      end
    end
    
    def count
      validations_hash.size
    end

    private

    def humanize(field)
      field.gsub(/[A-Z]/){ " #{$&.downcase}"}.capitalize
    end

    attr_accessor :validations_hash
  end
end
