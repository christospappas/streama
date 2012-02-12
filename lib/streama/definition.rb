module Streama
  
  class Definition
    
    attr_reader :name, :actor, :object, :target_object, :receivers
    
    # @param dsl [Streama::DefinitionDSL] A DSL object
    def initialize(definition)
      @name = definition[:name]
      @actor = definition[:actor] || {}
      @object = definition[:object] || {}
      @target_object = definition[:target_object] || {}
    end
    
    #
    # Registers a new definition
    #
    # @param definition [Definition] The definition to register
    # @return [Definition] Returns the registered definition
    def self.register(definition)
      return false unless definition.is_a? DefinitionDSL
      definition = new(definition)
      self.registered << definition
      return definition || false
    end
    
    # List of registered definitions
    # @return [Array<Streama::Definition>]
    def self.registered
      @definitions ||= []
    end
    
    def self.find(name)
      unless definition = registered.find{|definition| definition.name == name.to_sym}
        raise Streama::InvalidActivity, "Could not find a definition for `#{name}`"
      else
        definition
      end
    end
    
  end
  
end