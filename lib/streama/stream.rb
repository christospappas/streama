module Streama
  class Stream
    include Mongoid::Document
    
    field :receiver_id
    field :receiver_type
    field :activity_id
    
    def self.activities(receiver)
      where(:receiver_id => receiver.id, :receiver_type => receiver.class.name)
    end
    
    def self.deliver(activity, receivers)
      raise Streama::ActivityNotSaved if activity.new_record?
      batch = receivers.map do |receiver|
        {:receiver_id => receiver.id, :receiver_type => receiver.class.name, :activity_id => activity.id}
      end 
      !batch.empty? ? self.collection.insert(batch) : false
    end
    
    def self.find_by_actor(actor_id, actor_type)
      where(:receiver_id => actor_id, :reciever_type => actor_type)
    end
  
  
  end
end