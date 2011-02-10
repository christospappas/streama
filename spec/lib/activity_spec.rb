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
    it "should register and return a valid definition" do
      @definition.is_a?(Streama::Definition).should be true
    end
  end
  
  describe '#publish' do

    before :each do
      @activity = Streama::Activity.new_with_data(:new_enquiry, {:actor => user, :target => enquiry, :referrer => listing})
    end
    
    it "should return a list of stream entries" do
      @activity.save
      5.times { |n| User.create(:full_name => "Receiver #{n}") }
      @activity.publish.size.should eq 6
    end
  end
  
  describe '.new' do
    it "should create a new activity" do
      activity = Streama::Activity.new_with_data(:new_enquiry, {:actor => user, :target => enquiry, :referrer => listing})
      activity.should be_an_instance_of Streama::Activity
    end
  end
  
  # do this for actor and referrer as well
  describe '#target' do   
    before(:each) do
      @activity = Streama::Activity.new(:name => 'new_enquiry')
    end
    
    it "should write target metadata" do
      @activity.target = enquiry
      @activity.target[:comment].should eq "I'm interested"
    end
    
    it "should write target id" do
      @activity.target = enquiry
      @activity.target[:id].should_not be nil
    end
    
    it "should write target type" do
      @activity.target = enquiry
      @activity.target[:type].should_not be nil
    end
    
    it "should raise an exception if target object is not defined" do
      lambda { @activity.target = user }.should raise_error Streama::UndefinedData
    end
    
    it "should raise an exception if stored field definition is invalid" do
      lambda { @activity.target = listing }.should raise_error Streama::UndefinedField
    end
  end
  
end
