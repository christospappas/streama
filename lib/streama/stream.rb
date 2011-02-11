module Streama
  class Stream
    include Mongoid::Document
    
    field :receiver_id
    field :receiver_type
    field :activity_id
    field :activity_type
    
    def self.activities(receiver, type = nil)
      conditions = { :receiver_id => receiver.id, :receiver_type => receiver.class.name }
      conditions.merge!({:activity_type => type}) unless type.nil?
      where(conditions)
    end
    
    def self.deliver(activity, receivers)
      raise Streama::ActivityNotSaved if activity.new_record?
      batch = receivers.map do |receiver|
        {:receiver_id => receiver.id, 
         :receiver_type => receiver.class.name, 
         :activity_id => activity.id, 
         :activity_type => activity.name }
      end 
      !batch.empty? ? self.collection.insert(batch) : false
    end
  
  end
end