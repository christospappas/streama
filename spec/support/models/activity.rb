class Activity
  include Streama::Activity
  
  activity :enquiry do
    actor :user, :cache => [:full_name]
    object :enquiry, :cache => [:subject]
    target :listing, :cache => [:title]
  end
  
end