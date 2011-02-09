module Streama
  class Activity
    include Mongoid::Document
    include Mongoid::Timestamps
  
    field :verb,        :type => Symbol
    field :actor,       :type => Hash
    field :target,      :type => Hash
    field :referrer,    :type => Hash
  
    validates_presence_of :actor, :verb, :target
        
    #
    # Defines a new activity type
    #
    def self.define(name, &block)
      definition = Streama::DefinitionDSL.new(name)
      definition.instance_eval(&block)
      Streama::Definition.register(definition)
    end
    
    
    #
    # Creates a new instance using a verb and data
    # Sets the activity verb first before data.
    #
    def self.new_with_data(verb, data)
      new({:verb => verb}.merge(data))
    end
   
    def self.data_methods(*args)
      args.each do |method|
        define_method("#{method}=") { |*args| assign_metadata(method, args[0]) }
      end
    end
    data_methods :actor, :target, :referrer
   
    protected
   
    def assign_metadata(type, object)
      class_sym = object.class.name.downcase.to_sym
      type_sym = type.to_sym
      
      raise Streama::UndefinedData unless definition.send(type_sym).has_key?(class_sym)
      
      hash = {:id => object.id, :type => object.class.name}
      
      if fields = definition.send(type_sym)[class_sym][:store]
        fields.each do |field|
          raise Streama::UndefinedField unless object.respond_to?(field)
          hash[field] = object.send(field)
        end
      end
      write_attribute(type_sym, hash)      
    end
    
    def definition
      @definition ||= Streama::Definition.find(verb)
    end
    
  end
end