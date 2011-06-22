require 'active_support/core_ext/module/attribute_accessors'

lib_path = File.join(File.dirname(__FILE__),'lib')

# require lib files
['settings_lord','setting_creator','reflector','active_record','meta_setting_collection','meta_setting','version'].each do |file|
  require File.join(lib_path,'settings_lord',file)
end

# require generators
require File.join(lib_path,'generators','settings_lord','settings_lord_generator')

ActiveRecord::Base.send :extend, SettingsLord::ActiveRecord::ClassMethods

SettingsLord.check_active_record!
SettingsLord.setup_plugin!
