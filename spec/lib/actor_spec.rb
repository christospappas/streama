require "benchmark"
require 'spec_helper'

describe "Actor" do
  
  let(:enquiry) { Enquiry.create(:comment => "I'm interested") }
  let(:listing) { Listing.create(:title => "A test listing") }
  let(:user) { User.create(:full_name => "Christos") }
  
  before :all do
    Streama::Activity.define :new_comment do
      actor :user, :store => [:full_name]
      target :listing, :store => [:title]
      referrer :listing, :store => [:title]
    end
  end
  
  describe "#publish_activity" do
    
    before :each do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
    end
    
    it "pushes activity to receivers" do
      response = user.publish_activity(:new_enquiry, :target => enquiry, :referrer => listing)
      response.size.should eq 6
    end
    
    it "pushes to a defined stream" do
      response = user.publish_activity(:new_enquiry, :target => enquiry, :referrer => listing, :receivers => :friends)
      response.size.should eq 6
    end
    
  end
  
  describe "#activity_stream" do
    
    before :each do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      user.publish_activity(:new_enquiry, :target => enquiry, :referrer => listing)
      user.publish_activity(:new_comment, :target => listing)
    end
    
    it "retrieves the stream for an actor" do
      user.activity_stream.size.should eq 2
    end
    
    it "retrieves the stream and filter to a particular activity type" do
      user.activity_stream(:type => :new_comment).size.should eq 1
    end
    
    it "paginates the stream" do
      
      10.times { user.publish_activity(:new_comment, :target => listing) }
      
      activity = user.activity_stream(:page => 1, :per_page => 5)
      activity.size.should eq 5
    end
    
  end
  
  
end