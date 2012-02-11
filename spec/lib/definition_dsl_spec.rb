require 'spec_helper'

describe "Definition" do
  
  let(:definition_dsl) {Streama::DefinitionDSL.new(:new_photo)}
  
  it "initializes with name" do
    definition_dsl.attributes[:name].should eq :new_photo
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
  
  it "adds an object to the definition" do
    dsl = definition_dsl
    dsl.object(:photo_album, :cache => [:id, :title])
    dsl.attributes[:object].should eq :photo_album => { :cache=>[:id, :title] }
  end

  it "adds a target to the definition" do
    dsl = definition_dsl
    dsl.target(:company, :cache => [:id, :name])
    dsl.attributes[:target].should eq :company => { :cache=>[:id, :name] }
  end
  
end
