require 'spec_helper'

describe "Actor" do

  let(:enquiry) { Enquiry.create(:comment => "I'm interested") }
  let(:listing) { Listing.create(:title => "A test listing") }
  let(:user) { User.create(:full_name => "Christos") }

  new_activities  = [:new_enquiry, :new_enquiry_without_cache]

  before :all do
    Activity.activity :new_comment do
      actor :user, :cache => [:full_name]
      object :listing, :cache => [:title]
      target :listing, :cache => [:title]
    end

    Activity.activity :new_enquiry_without_cache do
      actor :user
      object :enquiry
      object :listing
      target :listing
    end

  end

  new_activities.each do |new_activity|
    describe "#publish_activity" do
      before :each do
        5.times { |n| User.create(:full_name => "Receiver #{n}") }
      end

      it "pushes activity to receivers" do
        activity = user.publish_activity(new_activity, :object => enquiry, :target => listing)
        activity.receivers.size == 6
      end

      it "pushes to a defined stream" do
        activity = user.publish_activity(new_activity, :object => enquiry, :target => listing, :receivers => :friends)
        activity.receivers.size == 6
      end
    end

  end

  new_activities.each do |new_activity|
    describe "#activity_stream" do

      before :each do
        5.times { |n| User.create(:full_name => "Receiver #{n}") }
        user.publish_activity(new_activity, :object => enquiry, :target => listing)
        user.publish_activity(:new_comment, :object => listing)
      end

      it "retrieves the stream for an actor" do
        user.activity_stream.size.should eq 2
      end

      it "retrieves the stream and filters to a particular activity type" do
        user.activity_stream(:type => :new_comment).size.should eq 1
      end

    end
  end


end
