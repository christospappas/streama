module Streama
  class Activity
    include Mongoid::Document
    include Mongoid::Timestamps
    
    store_in :activities
    
    field :name,        :type => Symbol
    field :actor,       :type => Hash
    field :target,      :type => Hash
    field :referrer,    :type => Hash
    
    references_many :streams, :class_name => "Streama::Stream", :dependent => :destroy
    
    index :name
    index [['actor._id', Mongo::ASCENDING], ['actor._type', Mongo::ASCENDING]]
    index [['target._id', Mongo::ASCENDING], ['target._type', Mongo::ASCENDING]]
    index [['referrer._id', Mongo::ASCENDING], ['referrer._type', Mongo::ASCENDING]]
    
    attr_accessor :actor_instance
    
    validates_presence_of :actor, :name, :target
    before_save :assign_data
    
    # Defines a new activity type and registers a definition
    #
    # @param [ String ] name The name of the activity
    #
    # @example Define a new activity
    #   Streama::Activity.define(:enquiry) do
    #     actor :user, :store => [:full_name]
    #     target :enquiry, :store => [:subject]
    #     referrer :listing, :store => [:title]
    #   end
    #
    # @return [Definition] Returns the registered definition
    def self.define(name, &block)
      definition = Streama::DefinitionDSL.new(name)
      definition.instance_eval(&block)
      Streama::Definition.register(definition)
    end

    # Creates a new instance using an activity name and data
    #
    # Sets the activity name first before data.
    #
    # @param [ String ] name The name of the activity
    # @param [ Hash ] data The data to initialize the activity with.
    #
    # @return [Streama::Activity] An Activity instance with data
    def self.new_with_data(name, data)
      new({:name => name}.merge(data))
    end

    # Publishes the activity to the receivers
    #
    # @param [ Hash ] options The options to publish with.
    #
    # @example publish an activity with a target and referrer
    #   current_user.publish_activity(:enquiry, :target => @enquiry, :referrer => @listing)
    #
    def publish(options = {})
      receivers = options.delete(:receivers) || :default
      actor = instance(:actor)
      streams = actor.class.streams

      raise Streama::InvalidStreamDefinition if receivers.is_a?(Symbol) && !streams.has_key?(receivers)      
      receivers = actor.send(streams[receivers][:followers]) if receivers.is_a?(Symbol)
    
      self.save
                  
      Streama::Stream.deliver(self, receivers)
    end

    # Returns an instance of an actor, target or referrer
    #
    # @param [ Symbol ] type The data type (actor, target, referrer) to return an instance for.
    #
    # @return [Object] object An object instance
    def load_instance(type)
      (data = self.send(type)).is_a?(Hash) ? data['type'].to_s.camelcase.constantize.find(data['id']) : data
    end
    
    def refresh_data
      assign_data
      save
    end
    
  protected
  
    def assign_data
      
      [:actor, :target, :referrer].each do |type|
        next unless object = instance(type)

        class_sym = object.class.name.underscore.to_sym

        raise Streama::InvalidData.new(class_sym) unless definition.send(type).has_key?(class_sym)
      
        hash = {'id' => object.id, 'type' => object.class.name}
                
        if fields = definition.send(type)[class_sym][:store]
          fields.each do |field|
            raise Streama::InvalidField.new(field) unless object.respond_to?(field)
            hash[field.to_s] = object.send(field)
          end
        end
        write_attribute(type, hash)      
      end
    end
    
    def definition
      @definition ||= Streama::Definition.find(name)
    end
    
  end
end