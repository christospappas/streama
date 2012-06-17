module Streama
  
  module Errors
  
    class StreamaError < StandardError
    end
  
    class InvalidActivity < StreamaError
    end
  
    # This error is raised when an object isn't defined
    # as an actor, object or target
    #
    # Example:
    #
    # <tt>InvalidField.new('field_name')</tt>
    class InvalidData < StreamaError
      attr_reader :message

      def initialize message
        @message = "Invalid Data: #{message}"
      end

    end
  
    # This error is raised when trying to store a field that doesn't exist
    #
    # Example:
    #
    # <tt>InvalidField.new('field_name')</tt>
    class InvalidField < StreamaError
      attr_reader :message

      def initialize message
        @message = "Invalid Field: #{message}"
      end

    end
  
    class ActivityNotSaved < StreamaError
    end
  
    class NoFollowersDefined < StreamaError
    end
  
    class NotMongoid < StreamaError
    end
    
  end
  
end