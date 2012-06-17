class User
  include Mongoid::Document
  include Streama::Actor
  
  field :full_name
  
  def friends
    self.class.all
  end
  
  def followers
    self.class.all
  end
  
end