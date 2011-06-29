module SettingsLord

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
