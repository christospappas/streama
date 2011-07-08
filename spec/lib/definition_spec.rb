require 'spec_helper'

describe "Definition" do
  
  let(:definition_dsl) do
    dsl = Streama::DefinitionDSL.new(:new_enquiry)
    dsl.actor(:user, :cache => [:id, :full_name])
    dsl.object(:enquiry, :cache => [:id, :full_name])
    dsl.target(:listing, :cache => [:id, :name, :full_address])
    dsl.receiver(:user, :cache => [])
    dsl
  end
  
  describe '#initialize' do
    before(:all) do
      @definition_dsl = definition_dsl
      @definition = Streama::Definition.new(@definition_dsl)
    end
    
    it "assigns @actor" do
      @definition.actor.has_key?(:user).should be true
    end
    it "assigns @object" do
      @definition.object.has_key?(:enquiry).should be true
    end
    
    it "assigns @target" do
      @definition.target.has_key?(:listing).should be true
    end

    it "assigns @receiver" do
      @definition.receiver.has_key?(:user).should be true
    end
    
  end
  
  describe '.register' do
    
    it "registers a definition and return new definition" do
      Streama::Definition.register(definition_dsl).is_a?(Streama::Definition).should eq true
    end
    
    it "returns false if invalid definition" do
      Streama::Definition.register(false).should be false
    end
    
  end
  
  describe '.registered' do
    
    it "returns registered definitions" do
      Streama::Definition.register(definition_dsl)
      Streama::Definition.registered.size.should be > 0
    end
    
  end
  
  describe '.find' do
    
    it "returns the definition by name" do
      Streama::Definition.find(:new_enquiry).name.should eq :new_enquiry
    end
    
    it "raises an exception if invalid activity" do
      lambda { Streama::Definition.find(:unknown_activity) }.should raise_error Streama::InvalidActivity
    end
    
  end
  
end
