require 'spec_helper'

describe "Actor" do
  
  let(:enquiry) { Enquiry.create(:comment => "I'm interested") }
  let(:listing) { Listing.create(:title => "A test listing") }
  let(:user) { User.create(:full_name => "Christos") }

  before :all do
    Activity.activity :new_comment do
      actor :user, :cache => [:full_name]
      object :listing, :cache => [:title]
      target :listing, :cache => [:title]
      receiver :user, :cache => []
    end

    Activity.activity :new_enquiry do
      actor :user, :cache => [:full_name]
      object :enquiry, :cache => [:comment]
      target :listing, :cache => [:title]
      receiver :user, :cache => []
    end
  end

  describe "#publish_activity" do

    before :each do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
    end

    it "pushes activity to receivers" do
      activity = user.publish_activity(:new_enquiry, :object => enquiry, :target => listing)

      Activity.where({ "receiver.id" => user.id, "receiver.type" => user.class.to_s }).count == user.followers.size
    end

  end

  describe "#publish_activity_with_receiver" do

    receivers = []

    before :each do
      5.times { |n| receivers << User.create(:full_name => "Receiver #{n}") }
    end
    
    it "pushes activity to receivers" do
      receivers.each do |receiver|
        activity = user.publish_activity(:new_enquiry, :object => enquiry, :target => listing, :receiver => receiver)
      end

      Activity.where({ "receiver.id" => user.id, "receiver.type" => user.class.to_s }).count == receivers.size
    end
    
  end

  describe "#publish_activity_with_receivers" do

    receivers = []

    before :each do
      5.times { |n| receivers << User.create(:full_name => "Receiver #{n}") }
    end

    it "pushes activity to receivers" do
      activity = user.publish_activity(:new_enquiry, :object => enquiry, :target => listing, :receivers => receivers)

      Activity.where({ "receiver.id" => user.id, "receiver.type" => user.class.to_s }).count == receivers.size
    end

  end

  describe "#publish_activity_with_receivers_symbol" do

    before :each do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
    end

    it "pushes activity to receivers" do
      activity = user.publish_activity(:new_enquiry, :object => enquiry, :target => listing, :receivers => :friends)

      Activity.where({ "receiver.id" => user.id, "receiver.type" => user.class.to_s }).count == user.friends.size
    end

  end
  
  describe "#activity_stream" do

    receivers = []

    before :each do
      5.times { |n| receivers << User.create(:full_name => "Receiver #{n}") }
      receivers[0].publish_activity(:new_enquiry, :object => enquiry, :target => listing, :receiver => user)
      receivers[1].publish_activity(:new_comment, :object => listing, :receiver => user)
    end
    
    it "retrieves the stream for an actor" do
      user.activity_stream.size.should eq 2
    end
    
    it "retrieves the stream and filters to a particular activity type" do
      user.activity_stream(:type => :new_comment).size.should eq 1
    end
        
  end
  
  
end