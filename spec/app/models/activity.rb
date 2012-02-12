class Activity
  include Streama::Activity
  
  activity :new_photo do
    actor :user, :cache => [:full_name]
    object :photo, :cache => [:file]
    target_object :album, :cache => [:title]
  end
  
  activity :new_photo_without_cache do
    actor :user
    object :photo
    target_object :album
  end
  
  activity :new_comment do
    actor :user, :cache => [:full_name]
    object :photo
  end
    
end