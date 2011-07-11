module Streama
  module Activity
    extend ActiveSupport::Concern
    
    included do
      
      include Mongoid::Document
      include Mongoid::Timestamps
    
      field :verb,        :type => Symbol
      field :actor,       :type => Hash
      field :object,      :type => Hash
      field :target,      :type => Hash
      field :receiver,    :type => Hash
          
      index :name
      index [['actor._id', Mongo::ASCENDING], ['actor._type', Mongo::ASCENDING]]
      index [['object._id', Mongo::ASCENDING], ['object._type', Mongo::ASCENDING]]
      index [['target._id', Mongo::ASCENDING], ['target._type', Mongo::ASCENDING]]
      index [['receiver._id', Mongo::ASCENDING], ['receiver._type', Mongo::ASCENDING]]
          
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
      #     target :listing, :cache => [:title]
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
        activity = new({:verb => verb}.merge(data))
        activity.save
        activity
      end
      
      def stream_for(actor, options={})
        query = { "receiver.id" => actor.id, "receiver.type" => actor.class.to_s }
        query.merge!({:verb => options[:type]}) if options[:type]
        self.where(query).desc(:created_at)
      end

    end


    module InstanceMethods

      # Returns an instance of an actor, object or target
      #
      # @param [ Symbol ] type The data type (actor, object, target) to return an instance for.
      #
      # @return [Mongoid::Document] document A mongoid document instance
      def load_instance(type)
        (data = self.send(type)).is_a?(Hash) ? data['type'].to_s.camelcase.constantize.find(data['id']) : data
      end
    
      def refresh_data
        assign_data
        save(:validate => false)
      end
    
      protected
        
      def assign_data
      
        [:actor, :object, :target, :receiver].each do |type|
          next unless object = load_instance(type)

          class_sym = object.class.name.underscore.to_sym

          raise Streama::InvalidData.new(class_sym) unless definition.send(type).has_key?(class_sym)

          hash = {'id' => object.id, 'type' => object.class.name}

          if fields = definition.send(type)[class_sym][:cache]
            fields.each do |field|
              raise Streama::InvalidField.new(field) unless object.respond_to?(field)
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
end