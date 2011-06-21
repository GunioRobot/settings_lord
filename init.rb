require 'active_support/core_ext/module/attribute_accessors'

lib_path = File.join(File.dirname(__FILE__),'lib')

# require lib files
['optionator','option_creator','reflector','active_record','meta_option_collection','meta_option','version'].each do |file|
  require File.join(lib_path,'optionator',file) 
end

# require generators
require File.join(lib_path,'generators','optionator','optionator_generator')

ActiveRecord::Base.send :extend, Optionator::ActiveRecord::ClassMethods

Optionator.check_active_record!
Optionator.setup_plugin!
