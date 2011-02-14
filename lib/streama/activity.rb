module Streama
  class Activity
    include Mongoid::Document
    include Mongoid::Timestamps
    
    store_in :activities
    
    field :name,        :type => Symbol
    field :actor,       :type => Hash
    field :target,      :type => Hash
    field :referrer,    :type => Hash
    
    index :name
    index [['actor._id', Mongo::ASCENDING], ['actor._type', Mongo::ASCENDING]]
    index [['target._id', Mongo::ASCENDING], ['target._type', Mongo::ASCENDING]]
    index [['referrer._id', Mongo::ASCENDING], ['referrer._type', Mongo::ASCENDING]]
    
    attr_accessor :actor_instance
    
    validates_presence_of :actor, :name, :target
    before_save :assign_data
    
    #
    # Defines a new activity type
    #
    def self.define(name, &block)
      definition = Streama::DefinitionDSL.new(name)
      definition.instance_eval(&block)
      Streama::Definition.register(definition)
    end

    #
    # Creates a new instance using an activity name and data
    # Sets the activity name first before data.
    #
    def self.new_with_data(name, data)
      new({:name => name}.merge(data))
    end

    def publish(options = {})
      receivers = options.delete(:receivers) || :default
      actor = instance(:actor)
      streams = actor.class.streams

      raise Streama::UnknownStreamDefinition if receivers.is_a?(Symbol) && !streams.has_key?(receivers)      
      receivers = actor.send(streams[receivers][:followers]) if receivers.is_a?(Symbol)
    
      self.save
                  
      Stream.deliver(self, receivers)
    end
    
    def instance(type)
      (data = self.send(type)).is_a?(Hash) ? data[:type].to_s.camelcase.constantize.find(data[:id]) : data
    end
    
  protected
  
    def assign_data
      
      [:actor, :target, :referrer].each do |type|
        next unless object = instance(type)
        
        class_sym = object.class.name.underscore.to_sym

        raise Streama::UndefinedData unless definition.send(type).has_key?(class_sym)
      
        hash = {:id => object.id, :type => object.class.name}
      
        if fields = definition.send(type)[class_sym][:store]
          fields.each do |field|
            raise Streama::UndefinedField unless object.respond_to?(field)
            hash[field] = object.send(field)
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