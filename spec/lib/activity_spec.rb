require 'spec_helper'

describe "Activity" do

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

  describe '.define' do
    it "registers and return a valid definition" do
      @definition.is_a?(Streama::Definition).should be true
    end
  end
  
  describe '#publish' do

    before :each do
      @actor = user
      @activity = Streama::Activity.new_with_data(:new_enquiry, {:actor => @actor, :target => enquiry, :referrer => listing})
    end
    
    it "returns a list of stream entries" do
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      @activity.publish.size.should eq 6
    end
    
    it "overrides the streams recievers if option passed" do
      send_to = []
      2.times { |n| send_to << User.create(:full_name => "Custom Receiver #{n}") }
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      @activity.publish(:receivers => send_to).size.should eq 2
    end
    
    context "when republishing"
      before :each do
        @activity.publish
      end
      
      it "updates metadata" do
        @actor.full_name = "testing"
        @actor.save
        @activity.publish
        @activity.actor[:full_name].should eq "testing"

      end
  end
  
  describe '.new' do
    it "creates a new activity" do
      activity = Streama::Activity.new_with_data(:new_enquiry, {:actor => user, :target => enquiry, :referrer => listing})
      activity.should be_an_instance_of Streama::Activity
    end
  end

  describe '#instance' do
    
    before :each do
      @activity = Streama::Activity.new_with_data(:new_enquiry, {:actor => user, :target => enquiry, :referrer => listing})
    end
    
    it "loads an actor instance" do
      @activity.instance(:actor).should be_instance_of User
    end
    
    it "loads a target instance" do
      @activity.instance(:target).should be_instance_of Enquiry
    end
    
    it "loads a referrer instance" do
      @activity.instance(:referrer).should be_instance_of Listing
    end
    
  end
  
end
