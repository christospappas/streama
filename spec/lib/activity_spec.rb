require 'spec_helper'

describe "Activity" do

  let(:photo) { Photo.create(:title => "fluffy cat", :url => "my_fluffy_cat.jpg") }
  let(:photo_album) { PhotoAlbum.create(:title => "Martin's Photo Album") }
  let(:user) { User.create(:full_name => "Martin Smith") }

  describe ".activity" do
    it "registers and return a valid definition" do
      @definition = Activity.activity(:test_activity) do
        actor :user, :cache => [:full_name]
        object :photo, :cache => [:title, :url]
        target :photo_album, :cache => [:title]
      end
      
      @definition.is_a?(Streama::Definition).should be true
    end
    
  end
  
  describe "#publish" do

    before :each do
      @send_to = []
      2.times { |n| @send_to << User.create(:full_name => "Custom Receiver #{n}") }
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
    end
    
    it "pushes activity to receivers" do
      @activity = Activity.publish(:new_photo, {:actor => user, :object => photo, :target => photo_album, :receivers => @send_to})
      @activity.receivers.size.should == 2
    end


    context "when activity not cached" do
      
      it "pushes activity to receivers" do
        @activity = Activity.publish(:new_photo_without_cache, {:actor => user, :object => photo, :target => photo_album, :receivers => @send_to})
        @activity.receivers.size.should == 2
      end
      
    end
    
    it "overrides the receivers if option passed" do
      @activity = Activity.publish(:new_photo, {:actor => user, :object => photo, :target => photo_album, :receivers => @send_to})
      @activity.receivers.size.should == 2
    end
    

    
    context "when republishing"
      before :each do
        @actor = user
        @activity = Activity.publish(:new_photo, {:actor => @actor, :object => photo, :target => photo_album})
        @activity.publish
      end
      
      it "updates metadata" do
        @actor.full_name = "testing"
        @actor.save
        @activity.publish
        @activity.actor['full_name'].should eq "testing"
      end
  end
  
  describe ".publish" do
    it "creates a new activity" do
      activity = Activity.publish(:new_photo, {:actor => user, :object => photo, :target => photo_album})
      activity.should be_an_instance_of Activity
    end
  end

  describe "#refresh" do
    
    before :each do
      @user = user
      @activity = Activity.publish(:new_photo, {:actor => @user, :object => photo, :target => photo_album})
    end
    
    it "reloads instances and updates activities stored data" do
      @activity.save
      @activity = Activity.last    
      
      expect do
        @user.update_attribute(:full_name, "Jessie Jones")
        @activity.refresh_data
      end.to change{ @activity.load_instance(:actor).full_name}.from("Martin Smith").to("Jessie Jones")
    end
    
  end

  describe "#load_instance" do
    
    before :each do
      @activity = Activity.publish(:new_photo, {:actor => user, :object => photo, :target => photo_album})
      @activity = Activity.last
    end
    
    it "loads an actor instance" do
      @activity.load_instance(:actor).should be_instance_of User
    end
    
    it "loads an object instance" do
      @activity.load_instance(:object).should be_instance_of Photo
    end
    
    it "loads a target instance" do
      @activity.load_instance(:target).should be_instance_of PhotoAlbum
    end
    
  end
  
end
