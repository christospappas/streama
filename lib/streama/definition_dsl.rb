module Streama
  
  class DefinitionDSL
    
    attr_reader :attributes
    
    def initialize(name)
      @attributes = {
        :name => name.to_sym,
        :actor => {}, 
        :object => {}, 
        :target_object => {}
      }
    end
    
    delegate :[], :to => :@attributes
        
    def self.data_methods(*args)
      args.each do |method|
        define_method method do |*args|
          @attributes[method].store(args[0].is_a?(Symbol) ? args[0] : args[0].class.to_sym, args[1])
        end
      end
    end
    data_methods :actor, :object, :target_object

  end
  
end