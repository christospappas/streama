module Streama
  class Activity
    include Mongoid::Document
    include Mongoid::Timestamps
  
    field :name,        :type => Symbol
    field :actor,       :type => Hash
    field :target,      :type => Hash
    field :referrer,    :type => Hash
  
    # references_many :streams
  
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

    def publish(name = :default, options = {})
      raise Streama::UnknownStreamDefinition unless actor_instance.class.streams.has_key?(name)
      save if new_record?
      receivers = actor_instance.send(actor_instance.class.streams[name][:followers])
      Streama::Stream.deliver(self, receivers)
    end
   
   
    protected
   ## CHANGE THIS TO BEFORE_SAVE
    def assign_data(type, object)
      class_sym = object.class.name.downcase.to_sym
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