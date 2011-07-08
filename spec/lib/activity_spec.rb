require 'spec_helper'

describe "Activity" do

  let(:enquiry) { Enquiry.create(:comment => "I'm interested") }
  let(:listing) { Listing.create(:title => "A test listing") }
  let(:user) { User.create(:full_name => "Christos") }
  let(:receiver) { User.create(:full_name => "Receiver") }

  describe '.activity' do
    it "registers and return a valid definition" do
      @definition = Activity.activity(:new_enquiry) do
        actor :user, :cache => [:full_name]
        object :enquiry, :cache => [:comment]
        object :listing, :cache => [:title, :full_address]
        target :listing, :cache => [:title]
        receiver :user, :cache => [:full_name]
      end
      
      @definition.is_a?(Streama::Definition).should be true
    end
  end
  
  #describe '#publish' do
    
  #  it "overrides the recievers if option passed" do
  #    send_to = []
  #    2.times { |n| send_to << User.create(:full_name => "Custom Receiver #{n}") }
  #    5.times { |n| User.create(:full_name => "Receiver #{n}") }
  #    @activity = Activity.publish(:new_enquiry, {:actor => user, :object => enquiry, :target => listing, :receivers => send_to})
  #    @activity.receivers.size.should == 2
  #  end
    
  #  context "when republishing"
  #    before :each do
  #      @actor = user
  #      @activity = Activity.publish(:new_enquiry, {:actor => @actor, :object => enquiry, :target => listing})
  #      @activity.publish
  #    end
      
  #    it "updates metadata" do
  #      @actor.full_name = "testing"
  #      @actor.save
  #      @activity.publish
  #      @activity.actor['full_name'].should eq "testing"
  #    end
  #end
  
  describe '.publish' do
    it "creates a new activity" do
      activity = Activity.publish(:new_enquiry, {:actor => user, :object => enquiry, :target => listing, :receiver => receiver})
      activity.should be_an_instance_of Activity
    end
  end

  describe '#refresh' do
    
    before :each do
      @user = user
      @activity = Activity.publish(:new_enquiry, {:actor => @user, :object => enquiry, :target => listing, :receiver => receiver})
    end
    
    it "reloads instances and updates activities stored data" do
      @activity.save
      @activity = Activity.last    
      
      expect do
        @user.update_attribute(:full_name, "Test")
        @activity.refresh_data
      end.to change{ @activity.load_instance(:actor).full_name}.from("Christos").to("Test")
    end
    
  end

  describe '#load_instance' do
    
    before :each do
      @activity = Activity.publish(:new_enquiry, {:actor => user, :object => enquiry, :target => listing, :receiver => receiver})
      @activity = Activity.last
    end
    
    it "loads an actor instance" do
      @activity.load_instance(:actor).should be_instance_of User
    end
    
    it "loads an object instance" do
      @activity.load_instance(:object).should be_instance_of Enquiry
    end
    
    it "loads a target instance" do
      @activity.load_instance(:target).should be_instance_of Listing
    end

    it "loads a receiver instance" do
      @activity.load_instance(:receiver).should be_instance_of User
    end
    
  end
  
end
