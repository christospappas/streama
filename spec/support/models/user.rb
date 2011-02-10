class User
  include Mongoid::Document
  include Streama::Actor
  
  activity_stream(:friends, :followers => :friends)
  
  field :full_name
  
  def friends
    self.class.all
  end
  
  
end