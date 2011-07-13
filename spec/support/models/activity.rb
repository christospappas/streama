class Activity
  include Streama::Activity
  
  activity :enquiry do
    actor :user, :cache => [:full_name]
    object :enquiry, :cache => [:comment]
    target :listing, :cache => [:title]
    receiver :user, :cache => []
  end
  
end