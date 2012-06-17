class NoMongoid
  include Streama::Actor
  
  field :full_name
  
  def followers
    self.class.all
  end
  
end