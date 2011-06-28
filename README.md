#SettingsLord
Easy way to manage your site settings

##Why?
Because we should create more cms-ready gems for rails.

##Requirements
Rails 3 only

##Install
add to your Gemfile:

	gem 'settings_lord'

##Overview
You can create settings via class methods:

	class Setting < ActiveRecord::Base

  	  settings do
   	    site_name :default => "RockBlogger"
   	  end

	end

After this you will be able to manipulate this setting:

	Setting.site_name # => "RockBlogger"
	Setting.site_name = "My blog about software"
	Setting.site_name # => "My blog about software"


You can store your settings in namespaces:

	# in class body
	settings :site do
	  name :default => "RockBlogger"	
	end

	# any other place	
	Setting.site.name # => "RockBlogger"
	Setting.site.name = "Rails notes"
	Setting.site.name # => "Rails notes"

	
What about settings freezing?

	settings :site do
	  developed_by :default => "Pechorin Andrey", :as_frozen => true
	end

	Setting.site.created_by # => "Pechorin Andrey"
	Setting.site.created_by = "some other person" # => will raise NoMethodError
	
You can cast values in many ways:

	settings do
	  year :default => 1990, :cast => lambda {|value| value.to_s + " year is now!"}
	  should_be_integer :default => 10 # will store 10 as string in database, but automatically create cast symbol -> :to_i
	  should_be_integer_with_cast :default => '10', :cast => :to_i
	end

	Setting.year # => "1990 year is now!"
	Setting.year = 2011
	Setting.year # => "2011 year is now!"
	
	Setting.should_be_integer.class # => Fixnum
	Setting.should_be_integer_with_cast.class # => Fixnum
	
What about booleans settings?

	settings :blog_settings do
	  comments_are_closed :default => false, :as_boolean => true
	end

	Setting.blog_settings.comments_are_closed # => false
	Setting.blog_settings.comments_are_closed = 10 # will cast 10 to true/false value ;)
	Setting.blog_settings.comments_are_closed # => true

You can limit accepted values:

	settings do
	  posts_per_page :accepted_values => 2..20 # Range
	  locale :accepted_values => [:ru,:en] # Array
	  support_email :accepted_values => /support@regexp/ # Regexp
	end

	Setting.posts_per_page = 12 # ok
	Setting.posts_per_page = 30 # => will raise Exception

All settings stored in database, but you can use in-memory settings

	settings do
	  memory_option :storage => :memory
	end
	
##What next?
* integration with other storages
* \_default\_value, \_before\_cast
