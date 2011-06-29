$:.push File.dirname(__FILE__)

require 'active_support/core_ext/module/attribute_accessors'

require 'settings_lord/base'
require 'settings_lord/setting_creator'
require 'settings_lord/reflector'
require 'settings_lord/active_record'
require 'settings_lord/meta_setting'
require 'settings_lord/meta_setting_collection'
require 'settings_lord/version'

require 'generators/settings_lord/settings_lord_generator'

# setup plugin
ActiveRecord::Base.send :extend, SettingsLord::ActiveRecord::ClassMethods
SettingsLord.check_active_record!
SettingsLord.setup_plugin!
