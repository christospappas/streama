module Streama
  
  module Actor
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        field :activities, :type => Array
      end
    end
    
    def log_activity(name, data={})
      activity = Streama::Activity.new_with_data(name, data)
      activity
    end
    
  end
  
end