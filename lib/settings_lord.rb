$:.push File.dirname(__FILE__)

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/dependencies'
require 'generators/settings_lord/settings_lord_generator'

module SettingsLord
	autoload :SettingCreator, 'settings_lord/setting_creator'
	autoload :Reflector, 'settings_lord/reflector'
	autoload :ActiveRecord, 'settings_lord/active_record'
	autoload :MetaSetting, 'settings_lord/meta_setting'
	autoload :MetaSettingCollection, 'settings_lord/meta_setting_collection'
	autoload :Version, 'settings_lord/version'


  ACTIVE_RECORD_COLUMNS = ['name','value','klass','parent_id']

  mattr_accessor :setting_creator
  mattr_accessor :meta_settings

  def self.check_active_record!
    ACTIVE_RECORD_COLUMNS.each do |column|
      unless Setting.column_names.include?(column)
        raise Exception, "Column '#{column}' doesn't exists in class #{self.name}!"
      end
    end
  end

  # Objects pool
  def self.setup_plugin!
    self.meta_settings ||= MetaSettingCollection.new
    self.setting_creator ||= SettingCreator.new
  end
end

# setup plugin
ActiveRecord::Base.send :extend, SettingsLord::ActiveRecord::ClassMethods
SettingsLord.check_active_record!
SettingsLord.setup_plugin!
