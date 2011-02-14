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
      
    validates_presence_of :actor, :name, :target
    
    attr_accessor :actor_instance
    
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

    def actor=(actor)
      assign_data(:actor, actor)
      self.actor_instance = actor
    end

    def self.data_methods(*args)
      args.each do |method|
        define_method("#{method}=") { |*args| assign_data(method, args[0]) }
      end
    end
    data_methods :target, :referrer

    def publish(options = {})
      receivers = options.delete(:receivers) || :default
      raise Streama::UnknownStreamDefinition if receivers.is_a?(Symbol) && !actor_instance.class.streams.has_key?(receivers)      
      
      save if new_record?
      
      receivers = actor_instance.send(actor_instance.class.streams[receivers][:followers]) if receivers.is_a?(Symbol)
      
      Stream.deliver(self, receivers)
    end
   
   
    protected
    def assign_data(type, object)
      class_sym = object.class.name.underscore.to_sym
      type = type.to_sym
      
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
    
    def definition
      @definition ||= Streama::Definition.find(name)
    end
    
  end
end