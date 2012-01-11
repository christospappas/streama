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
      def publish_activity(verb, options={})
        options[:receivers] = self.send(options[:receivers]) if options[:receivers].is_a?(Symbol)
        activity = activity_class.publish(verb, {:actor => self}.merge(options))
      end

      def update_or_publish_activity(verb, options={})
        # want to match object, actor ids, etc, and name
        # want to keep name
        # dont want to delete existing
        # later: send in update conditions.  now, update if less than a day old.
        # todo: abstract the matching of object/target
        # todo: recalculate receivers on update
        # assign_data is called on save, updating the data

        if activity = activity_class.where({'actor.id' => self.id,
                                            'verb' => verb,
                                            'object.id' => options[:object].id,
                                            :updated_at.gt => (Time.now - 1.day)}).first
          activity.save
        else
          publish_activity(verb, options)
        end

      end

      def activity_stream(options = {})
        p "Streama actor#activity_stream is deprecated in favor of actor#incoming_activity"
        incoming_activity options
      end

      def incoming_activity(options = {})
        activity_class.stream_for(self, options).limit(10)
      end

      def outgoing_activity(options = {})
        activity_class.stream_of(self, options).limit(10)
      end

      def activity_class
        @activity_klass ||= activity_klass ? activity_klass.classify.constantize : ::Activity
      end
    end

  end

end