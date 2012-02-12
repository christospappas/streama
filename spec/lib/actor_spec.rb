require 'spec_helper'

describe "Actor" do

  let(:photo) { Photo.create(:comment => "I'm interested") }
  let(:album) { Album.create(:title => "A test album") }
  let(:user) { User.create(:full_name => "Christos") }

  describe "#publish_activity" do
    before :each do
      2.times { |n| User.create(:full_name => "Receiver #{n}") }
    end

    it "pushes activity to receivers" do
      activity = user.publish_activity(:new_photo, :object => photo, :target_object => album)
      activity.receivers.size == 6
    end

    it "pushes to a defined stream" do
      activity = user.publish_activity(:new_photo, :object => photo, :target_object => album, :receivers => :friends)
      activity.receivers.size == 6
    end
    
  end

  describe "#activity_stream" do
    
    before :each do
      2.times { |n| User.create(:full_name => "Receiver #{n}") }
      user.publish_activity(:new_photo, :object => photo, :target_object => album)
      user.publish_activity(:new_comment, :object => photo)
    end

    it "retrieves the stream for an actor" do
      user.activity_stream.size.should eq 2
    end

    it "retrieves the stream and filters to a particular activity type" do
      user.activity_stream(:type => :new_photo).size.should eq 1
    end

  end


end
