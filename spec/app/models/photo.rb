class Photo
  include Mongoid::Document
  
  field :title
  field :url
  field :comment
  
end
