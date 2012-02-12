# Streama

**ALPHA**

Streama is a simple Ruby activity stream gem for use with the Mongoid ODM framework.

[![travis](https://secure.travis-ci.org/christospappas/streama.png)](http://travis-ci.org/christospappas/streama)

## Install

    gem install streama

## Usage

### Define Activities

Create an Activity model and define the activities and the fields you would like to cache within the activity.

An activity consists of an actor, a verb, an object, and a target. 

``` ruby
class Activity
  include Streama::Activity

  activity :new_photo do
    actor :user, :cache => [:full_name]
    object :photo, :cache => [:subject, :comment]
    target_object :album, :cache => [:title]
  end

end
```

The activity verb is implied from the activity name, in the above example the verb is :new_photo

The object may be the entity performing the activity, or the entity on which the activity was performed.
e.g John(actor) shared a video(object)

The target is the object that the verb is enacted on.
e.g. Geraldine(actor) posted a photo(object) to her album(target)

This is based on the Activity Streams 1.0 specification (http://activitystrea.ms)

### Setup Actors

Include the Actor module in a class and override the default followers method.

``` ruby
class User
	include Mongoid::Document
	include Streama::Actor

	field :full_name, :type => String

	def followers
		User.excludes(:id => self.id).all
	end
end
```

### Setup Indexes

Create the indexes for the Activities collection. You can do so by calling the create_indexes method.

``` ruby
Activity.create_indexes
```

### Publishing Activity

In your controller or background worker:

``` ruby
current_user.publish_activity(:new_photo, :object => @photo, :target_object => @album)
```
  
This will publish the activity to the mongoid objects returned by the #followers method in the Actor.

To send your activity to different receievers, pass in an additional :receivers parameter.

``` ruby
current_user.publish_activity(:new_photo, :object => @photo, :target_object => @album, :receivers => :friends) # calls friends method
```

``` ruby
current_user.publish_activity(:new_photo, :object => @photo, :target_object => @album, :receivers => current_user.find(:all, :conditions => {:group_id => mygroup}))
```

## Retrieving Activity

To retrieve all activity for an actor

``` ruby
current_user.activity_stream
```
  
To retrieve and filter to a particular activity type

``` ruby
current_user.activity_stream(:type => :activity_verb)
```
If you need to return the instance of an :actor, :object or :target_object from an activity call the Activity#load_instance method

``` ruby
activity.load_instance(:actor)
```
  
You can also refresh the cached activity data by calling the Activity#refresh_data method

``` ruby  
activity.refresh_data
```

## Upgrading

### 0.3.3

The Activity "target" field was renamed to "target_object". If you are upgrading from a previous version of Streama you will need to rename the field in existing documents.

http://www.mongodb.org/display/DOCS/Updating#Updating-%24rename

## Contributing

Once you've made your great commits

1. Fork
1. Create a topic branch - git checkout -b my_branch
1. Push to your branch - git push origin my_branch
1. Create a Pull Request from your branch
1. That's it!

## Contributors

* Christos Pappas		(@christospappas)