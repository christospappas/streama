module Streama
  class Stream
    include Mongoid::Document
    
    store_in :streams
    
    referenced_in :activity, :class_name => "Streama::Activity"
    
    field :receiver_id
    field :receiver_type
    field :activity_type
    field :created_at
    
    index [[:receiver_id, Mongo::ASCENDING], [:receiver_type, Mongo::ASCENDING], [:created_at, Mongo::DESCENDING]]
    index [[:activity_type, Mongo::ASCENDING], [:activity_id, Mongo::ASCENDING]]
    
    def self.deliver(activity, receivers)
      raise Streama::ActivityNotSaved if activity.new_record?
      batch = receivers.map do |receiver|
        {:receiver_id => receiver.id, 
         :activity_id => activity.id,
         :receiver_type => receiver.class.name, 
         :activity_type => activity.name,
         :created_at => Time.now }
      end

      !batch.empty? ? Streama::Stream.collection.insert(batch) : false
    end
  
  end
end