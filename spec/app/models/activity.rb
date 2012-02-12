class Activity
  include Streama::Activity
  
  activity :new_enquiry do
    actor :user, :cache => [:full_name]
    object :enquiry, :cache => [:comment]
    target_object :listing, :cache => [:title]
  end
  
  activity :new_enquiry_without_cache do
    actor :user
    object :enquiry
    target_object :listing
  end
  
  activity :new_comment do
    actor :user, :cache => [:full_name]
    object :listing
  end
    
end