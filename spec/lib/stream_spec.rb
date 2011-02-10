require 'spec_helper'

describe "Stream" do

  let(:enquiry) { Enquiry.create(:comment => "I'm interested") }
  let(:listing) { Listing.create(:title => "A test listing") }
  let(:user) { User.create(:full_name => "Christos") }

  before(:all) do
    @definition = Streama::Activity.define(:new_enquiry) do
      actor :user, :store => [:full_name]
      target :enquiry, :store => [:comment]
      target :listing, :store => [:title, :full_address]
      referrer :listing, :store => [:title]
    end    
  end
  
  describe ".deliver" do
    
    before :each do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      @activity = Streama::Activity.new_with_data(:new_enquiry, {:actor => user, :target => enquiry, :referrer => listing})
    end
    
    it "should raise an exception if the activity hasn't been saved" do
      lambda { Streama::Stream.deliver(@activity, User.all ) }.should raise_error Streama::ActivityNotSaved
    end
    
    it "should insert activity into receivers stream" do
      @activity.save
      Streama::Stream.deliver(@activity, User.all )
      Streama::Stream.count.should eq 6
    end
    
    it "should check if stream is valid before batch insert"
    
  end
  
  
end