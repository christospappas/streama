module Streama
  
  module Actor
    extend ActiveSupport::Concern

    included do
      cattr_accessor :activity_klass
    end

    module ClassMethods
          
      def activity_class(klass)
        self.activity_klass = klass.to_s
      end
      
    end

    module InstanceMethods
      
      # Publishes the activity to the receivers
      #
      # @param [ Hash ] options The options to publish with.
      #
      # @example publish an activity with a object and target
      #   current_user.publish_activity(:enquiry, :object => @enquiry, :target => @listing)
      #
      def publish_activity(name, options={})
        if options[:receivers]
          options[:receivers] = self.send(options[:receivers]) if options[:receivers].is_a?(Symbol)
        end
        activity = activity_class.publish(name, {:actor => self}.merge(options))
      end
    
      def activity_stream(options = {})
        activity_class.stream_for(self, options)
      end
      
      # Returns the activity stream of the actor's own activities.
      def actor_activity_stream(options = {})
        activity_class.actor_stream_for(self, options)
      end
      
      def activity_class
        @activity_klass ||= activity_klass ? activity_klass.classify.constantize : ::Activity
      end
    end
    
  end
  
end