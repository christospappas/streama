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
      def publish(verb, data)

        if data[:receiver]
          receiver = data.delete(:receiver)
          receivers = [ receiver ]
        else
          if data[:receivers]
            receivers = data.delete(:receivers)
          else
            receivers = data[:actor].followers
          end
        end

        #receivers.each do |receiver|
        #  activity = new({:verb => verb, :receiver => receiver}.merge(data))
        #  activity.save
        #end

        # Instead of iterating through all receivers and creating Mongoid objects for each activity
        # we're going to drop into the Mongo Ruby driver and use the batch insert for performance.
        batch_insert(verb, data, receivers)

      end
      
      def stream_for(actor, options={})
        query = { "receiver.id" => actor.id, "receiver.type" => actor.class.to_s }
        query.merge!({:verb => options[:type]}) if options[:type]
        self.where(query).desc(:created_at)
      end
      
      def actor_stream_for(actor, options={})
        query = { "receiver.id" => actor.id, "receiver.type" => actor.class.to_s, "actor.id" => actor.id }
        query.merge!({:verb => options[:type]}) if options[:type]
        self.where(query).desc(:created_at)
      end

      # Helper function called by publish to do batch insertions
      def batch_insert(verb, options, receivers)
        max_batch_size = 500
        definition = Streama::Definition.find(verb)

        # Need to construct the hash to pass into Mongo Ruby driver's batch insert
        batch = []
        receivers.each do |receiver|
          options[:receiver] = receiver

          activity = {}
          activity["verb"] = verb

          options.each_pair do |key,val|
            keyString = key.to_s
            activity[keyString] = {}
            activity[keyString]["type"] = val.class.to_s
            activity[keyString]["id"] = val._id

            definitionObj = definition.send key

            cacheFields = definitionObj[val.class.to_s.downcase.to_sym][:cache]
            cacheFields.each do |field|
              activity[keyString][field.to_s] = val.send field
            end
          end

          activity["created_at"] = Time.now
          activity["updated_at"] = activity["created_at"]

          batch << activity

          if batch.size % max_batch_size == 0
            self.collection.insert(batch)
            batch = []
          end
        end

        # Perform the batch insert
        self.collection.insert(batch)
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