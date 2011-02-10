module Streama
  
  module Actor
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        activity_stream(:default, :followers => :followers)
      end
    end
    
    def publish_activity(name, options={})
      stream = options.delete(:stream) || :default
      activity = Streama::Activity.new_with_data(name, {:actor => self}.merge(options))
      activity.publish(stream, self.class.streams[stream])
    end
    
    def activity_stream(stream = :default)
      Streama::Stream.activities(self)
    end
    
    def followers
      self.class.all
    end
    
    module ClassMethods
      
      attr_accessor :streams
      
      def activity_stream(name, options={})
        (self.streams ||= {})[name.to_sym] = options
      end
      
    end
    
  end
  
end