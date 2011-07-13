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
  
  describe '#publish' do
    
    it "overrides the recievers if option passed" do
      send_to = []
      2.times { |n| send_to << User.create(:full_name => "Custom Receiver #{n}") }
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      Activity.publish(:new_enquiry, {:actor => user, :object => enquiry, :target => listing, :receivers => send_to})
      Activity.count.should == send_to.size
    end
    
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
  end
  
  describe '.publish' do
    it "creates a new activity with single receiver" do
      Activity.publish(:new_enquiry, {:actor => user, :object => enquiry, :target => listing, :receiver => receiver})
      Activity.count.should == 1
    end

    it "creates new activities" do
      Activity.publish(:new_enquiry, {:actor => user, :object => enquiry, :target => listing})
      activities = Activity.all
      activities.count.should == user.followers.size
      activities.each do |activity|
        activity.should be_an_instance_of Activity
      end
    end
  end

  describe '#refresh' do

    before :each do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      @user = user
      @full_name = @user.full_name
      Activity.publish(:new_enquiry, {:actor => @user, :object => enquiry, :target => listing})
    end

    it "reloads instances and updates activities stored data" do
      # Load actor's activities
      @activities = Activity.where({ "actor.id" => @user.id, "actor.type" => @user.class.to_s })
      @activities.count.should == @user.followers.size

      activity = @activities.first

      expect do
        @user.update_attribute(:full_name, "Test")
        activity.refresh_data
      end.to change{ activity.load_instance(:actor).full_name}.from(@full_name).to("Test")
    end
    
  end

  describe '#load_instance' do

    before :each do
      Activity.publish(:new_enquiry, {:actor => user, :object => enquiry, :target => listing, :receiver => receiver})
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

  describe 'batch insertion test' do

    max_batch_size = 5
    num_followers = 10

    it "no batch insert" do

      (1..num_followers).each do |n|
        activity = Activity.new({:verb => :enquiry, :receiver => user, :actor => user, :object => enquiry, :target => listing})
      end
    end

    it "batch insert" do

      batch = []
      (1..num_followers).each do |n|
        activity = {}
        activity["actor"] = {}
        activity["actor"]["type"] = user.class.to_s
        activity["actor"]["id"] = user._id
        activity["actor"]["full_name"] = user.full_name

        activity["object"] = {}
        activity["object"]["type"] = enquiry.class.to_s
        activity["object"]["id"] = enquiry._id
        activity["object"]["comment"] = enquiry.comment

        activity["target"] = {}
        activity["target"]["type"] = listing.class.to_s
        activity["target"]["id"] = listing._id
        activity["target"]["title"] = listing.title

        activity["receiver"] = {}
        activity["receiver"]["id"] = receiver._id
        activity["receiver"]["type"] = receiver.class.to_s

        batch << activity

        if batch.size % max_batch_size == 0
          Activity.collection.insert(batch)
          batch = []
        end
      end

      Activity.collection.insert(batch)

      Activity.count.should == num_followers
      Activity.all.each do |a|

        a.load_instance(:actor).should be_instance_of User
        a.load_instance(:object).should be_instance_of Enquiry
        a.load_instance(:target).should be_instance_of Listing
        a.load_instance(:receiver).should be_instance_of User
      end
    end
  end

  describe 'batch insertion performance test' do

    max_batch_size = 500
    num_followers = 2000

    it "no batch insert" do

      (1..num_followers).each do |n|
        activity = Activity.new({:verb => :enquiry, :receiver => user, :actor => user, :object => enquiry, :target => listing})
      end
    end

    it "batch insert" do

      batch = []
      (1..num_followers).each do |n|
        activity = {}
        activity["actor"] = {}
        activity["actor"]["type"] = user.class.to_s
        activity["actor"]["id"] = user._id
        activity["actor"]["full_name"] = user.full_name

        activity["object"] = {}
        activity["object"]["type"] = enquiry.class.to_s
        activity["object"]["id"] = enquiry._id
        activity["object"]["comment"] = enquiry.comment

        activity["target"] = {}
        activity["target"]["type"] = listing.class.to_s
        activity["target"]["id"] = listing._id
        activity["target"]["title"] = listing.title

        activity["receiver"] = {}
        activity["receiver"]["id"] = receiver._id
        activity["receiver"]["type"] = receiver.class.to_s

        batch << activity

        if batch.size % max_batch_size == 0
          Activity.collection.insert(batch)
          batch = []
        end
      end

      Activity.collection.insert(batch)
    end

  end
  
end
