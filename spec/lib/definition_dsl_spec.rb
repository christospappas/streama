require 'spec_helper'

describe "Definition" do
  
  let(:definition_dsl) {Streama::DefinitionDSL.new(:new_enquiry)}
  
  it "initializes with name" do
    definition_dsl.attributes[:name].should eq :new_enquiry
  end
  
  it "adds an actor to the definition" do
    dsl = definition_dsl
    dsl.actor(:user, :cache => [:id, :full_name])
    dsl.attributes[:actor].should eq :user => { :cache=>[:id, :full_name] }
  end
  
  it "adds multiple actors to the definition" do
    dsl = definition_dsl
    dsl.actor(:user, :cache => [:id, :full_name])
    dsl.actor(:company, :cache => [:id, :name])
    dsl.attributes[:actor].should eq :user => { :cache=>[:id, :full_name] }, :company => { :cache=>[:id, :name] }
  end
  
  it "adds a target to the definition" do
    dsl = definition_dsl
    dsl.target(:listing, :cache => [:id, :title])
    dsl.attributes[:target].should eq :listing => { :cache=>[:id, :title] }
  end

  it "adds a referrer to the definition" do
    dsl = definition_dsl
    dsl.referrer(:company, :cache => [:id, :name])
    dsl.attributes[:referrer].should eq :company => { :cache=>[:id, :name] }
  end
  
end
