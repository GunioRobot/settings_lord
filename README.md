#Optionator
Easy way to manage your configurations

##Why?
Because we should create more cms-ready gems for rails.

##Examples
Look at this easy example

	class Option < ActiveRecord::Base
	
	  define_options do	|config|
	    config.site_name :default => "SuperBlogger"
	  end
	
	end
	
	Option.site_name # => SuperBlogger
	
Okay, what's cool, but what about namespace?

	define_options :site do |config|
	  config.name :default => "SuperBlogger"
	end
	
	###
	
	Option.site.name # => SuperBlogger
	
Can i set value?

	Option.site.name = "MyNewBlog"
	Option.site.name # => MyNewBlog
	
What if i want freeze my option?

	define_options :site do |config|
	  config.created_by :default => "pechorin andrey", :as_frozen => true
	end
	
	Option.site.created_by # => pechorin andrey
	Option.site.created_by = "some other person" # => will raise NoMethodError
	
Okay, nice, can i cast values?

	define_options do |config|
	  config.year :default => 1990, :cast => lambda {|value| value.to_s + " year"}
	  config.should_be_integer :default => 10
	  config.should_be_integer_with_cast :default => '10', :cast => :to_i
	end
	
	Option.year # => 1990 year
	Option.year = 2011
	Option.year # => 2011 year
	
	Option.should_be_integer.class # => Fixnum
	Option.should_be_integer_with_cast.class # => Fixnum
	
What about bools options?

	define_options do |config|
	  config.close_comments :default => false, :as_boolean => true
	end
	
	Option.close_comments # => false
	Option.close_comments = 10 # => will setup true, not 10 :)
	Option.close_comments # => true

And what about strong limitations?

	define_options do |config|
	  config.posts_per_page :default => 10, :accepted_values => 2..20 # range
	  config.locale :default => :ru, :accepted_values => [:ru,:en] # array
	  config.support_email :accepted_values => /support@regexp/ # regexp
	end
	
	Option.posts_per_page = 12
	Option.posts_per_page = 30 # => will raise Exception

Stop, all options place in Database, can i store option in memory?

	define_options do |config|
	  config.memory_option :storage => :memory
	end
	
##What next?
* integration with other storages
* \_default\_value, \_before\_cast