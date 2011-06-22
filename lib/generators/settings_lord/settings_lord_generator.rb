require 'rails/generators'

class SettingsLordGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)  

  def generate_settings_lord
    copy_file "migration.rb", "db/migrate/#{migration_time}_create_settings.rb"
    copy_file "setting.rb", "app/models/setting.rb"
  end

  def migration_time
    Time.now.strftime('%Y%m%d%H%M%S') 
  end

end  
