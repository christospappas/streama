class Activity
  include Streama::Activity
  
  activity :new_photo do
    actor :user, :cache => [:full_name]
    object :photo, :cache => [:comment]
    target :photo_album, :cache => [:title]
  end
  
  activity :new_photo_without_cache do
    actor :user
    object :photo
    target :photo_album
  end
  
  activity :new_comment do
    actor :user, :cache => [:full_name]
    object :photo_album
  end
    
end
