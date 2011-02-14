module Streama
  class Stream
    include Mongoid::Document
    
    store_in :streams
    
    field :receiver_id
    field :receiver_type
    field :activity_id
    field :activity_type
    field :created_at
    
    index [[:receiver_id, Mongo::ASCENDING], [:receiver_type, Mongo::ASCENDING], [:created_at, Mongo::DESCENDING]]
    index [[:activity_type, Mongo::ASCENDING], [:activity_id, Mongo::ASCENDING]]
    
    def self.activities(receiver, type = nil)
      conditions = { :receiver_id => receiver.id, :receiver_type => receiver.class.name }
      conditions.merge!({:activity_type => type}) unless type.nil?
      where(conditions).desc(:created_at)
    end
    
    def self.deliver(activity, receivers)
      raise Streama::ActivityNotSaved if activity.new_record?
      batch = receivers.map do |receiver|
        {:receiver_id => receiver.id, 
         :receiver_type => receiver.class.name, 
         :activity_id => activity.id, 
         :activity_type => activity.name,
         :created_at => Time.now }
      end

      !batch.empty? ? Stream.collection.insert(batch) : false
    end
  
  end
end