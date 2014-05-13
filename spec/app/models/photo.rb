class Photo
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :file

end
