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
          class_sym = if class_name = args[1].try(:delete,:class_name)
                        class_name.underscore.to_sym
                      else
                        args[0].is_a?(Symbol) ? args[0] : args[0].class.to_sym
                      end
          @attributes[method].store(class_sym, args[1])
        end
      end
    end
    data_methods :actor, :object, :target_object

  end

end
