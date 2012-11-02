module Streama
  module Activity
    extend ActiveSupport::Concern

    included do

      include Mongoid::Document
      include Mongoid::Timestamps

      field :verb,          :type => Symbol
      field :actor
      field :object
      field :target_object
      field :receivers,     :type => Array

      index :name => 1
      index({ 'actor._id' => 1, 'actor._type' => 1 })
      index({ 'object._id' => 1, 'object._type' => 1 })
      index({ 'target_object._id' => 1, 'target_object._type' => 1 })
      index({ 'receivers.id' => 1, 'receivers.type' => 1 })

      validates_presence_of :actor, :verb
      before_save :assign_data

    end

    module ClassMethods

      # Defines a new activity type and registers a definition
      #
      # @param [ String ] name The name of the activity
      #
      # @example Define a new activity
      #   activity(:enquiry) do
      #     actor :user, :cache => [:full_name]
      #     object :enquiry, :cache => [:subject]
      #     target_object :listing, :cache => [:title]
      #   end
      #
      # @return [Definition] Returns the registered definition
      def activity(name, &block)
        definition = Streama::DefinitionDSL.new(name)
        definition.instance_eval(&block)
        Streama::Definition.register(definition)
      end

      # Publishes an activity using an activity name and data
      #
      # @param [ String ] verb The verb of the activity
      # @param [ Hash ] data The data to initialize the activity with.
      #
      # @return [Streama::Activity] An Activity instance with data
      def publish(verb, data)
        receivers = data.delete(:receivers)
        new({:verb => verb}.merge(data)).publish(:receivers => receivers)
      end

      def stream_for(actor, options={})
        query = {:receivers => {'$elemMatch' => {:id => actor.id, :type => actor.class.to_s}}}
        query.merge!({:verb.in => [*options[:type]]}) if options[:type]
        self.where(query).without(:receivers).desc(:created_at)
      end

      def stream_of(actor, options={})
         query = {'actor.id' => actor.id, 'actor.type' => actor.class.to_s}
         query.merge!({:verb.in => [*options[:type]]}) if options[:type]
         self.where(query).without(:receivers).desc(:created_at)
      end

    end


    # Publishes the activity to the receivers
    #
    # @param [ Hash ] options The options to publish with.
    #
    def publish(options = {})
      actor = load_instance(:actor)
      self.receivers = (options[:receivers] || actor.followers).map { |r| { :id => r.id, :type => r.class.to_s } }
      self.save
      self
    end

    # Returns an instance of an actor, object or target
    #
    # @param [ Symbol ] type The data type (actor, object, target) to return an instance for.
    #
    # @return [Mongoid::Document] document A mongoid document instance
    def load_instance(type)
      (data = self.read_attribute(type)).is_a?(Hash) ? data['type'].to_s.camelcase.constantize.find(data['id']) : data
    end

    def refresh_data
      assign_data
      save(:validates_presence_of => false)
    end

    protected

    def assign_data

      [:actor, :object, :target_object].each do |type|
        next unless object = load_instance(type)

        class_sym = object.class.name.underscore.to_sym

        raise Errors::InvalidData.new(class_sym) unless definition.send(type).has_key?(class_sym)

        hash = {'id' => object.id, 'type' => object.class.name}

        if fields = definition.send(type)[class_sym].try(:[],:cache)
          fields.each do |field|
            raise Errors::InvalidField.new(field) unless object.respond_to?(field)
            hash[field.to_s] = object.send(field)
          end
        end
        write_attribute(type, hash)
      end
    end

    def definition
      @definition ||= Streama::Definition.find(verb)
    end

  end
end
