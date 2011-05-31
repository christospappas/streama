class Activity
  include Streama::Activity
  
  activity :enquiry do
    actor :user, :cache => [:full_name]
    target :enquiry, :cache => [:subject]
    referrer :listing, :cache => [:title]
  end
  
end