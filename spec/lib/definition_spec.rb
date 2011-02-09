require 'spec_helper'

describe "Definition" do
  
  let(:definition_dsl) do
    dsl = Streama::DefinitionDSL.new(:new_enquiry)
    dsl.actor(:user, :store => [:id, :full_name])
    dsl.target(:enquiry, :store => [:id, :full_name])
    dsl.referrer(:listing, :store => [:id, :name, :full_address])
    dsl
  end
  
  describe '#initialize' do
    before(:all) do
      @definition_dsl = definition_dsl
      @definition = Streama::Definition.new(@definition_dsl)
    end
    
    it "should assign @actor" do
      @definition.actor.has_key?(:user).should be true
    end
    it "should assign @target" do
      @definition.target.has_key?(:enquiry).should be true
    end
    
    it "should assign @referrer" do
      @definition.referrer.has_key?(:listing).should be true
    end
    
  end
  
  describe '.register' do
    
    it "should register a definition and return new definition" do
      Streama::Definition.register(definition_dsl).is_a?(Streama::Definition).should eq true
    end
    
    it "should return false if invalid definition" do
      Streama::Definition.register(false).should be false
    end
    
  end
  
  describe '.registered' do
    
    it "should return registered definitions" do
      Streama::Definition.register(definition_dsl)
      Streama::Definition.registered.size.should be > 0
    end
    
  end
  
  describe '.find' do
    
    it "should return the definition by name" do
      Streama::Definition.find(:new_enquiry).name.should eq :new_enquiry
    end
    
    it "should raise an exception if invalid activity" do
      lambda { Streama::Definition.find(:unknown_activity) }.should raise_error Streama::UndefinedActivity
    end
    
  end
  
end
