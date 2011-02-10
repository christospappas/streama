require "benchmark"
require 'spec_helper'

describe "Actor" do
  
  let(:enquiry) { Enquiry.create(:comment => "I'm interested") }
  let(:listing) { Listing.create(:title => "A test listing") }
  let(:user) { User.create(:full_name => "Christos") }
  
  before(:all) do
    @definition = Streama::Activity.define(:new_enquiry) do
      actor :user, :store => [:full_name]
      target :enquiry, :store => [:comment]
      referrer :listing, :store => [:title]
    end    
  end

  
  describe "#publish_activity" do
    
    it "should push activity to receivers" do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      response = user.publish_activity(:new_enquiry, :target => enquiry, :referrer => listing)
      response.size.should eq 6
    end
    
    it "should set the stream to push to" do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      response = user.publish_activity(:new_enquiry, :target => enquiry, :referrer => listing, :stream => :friends)
      response.size.should eq 6
    end
    
  end
  
  
end