class User
  include Mongoid::Document
  include Streama::Actor
  
  field :full_name
  
end