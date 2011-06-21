require 'rails/generators'

class OptionatorGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)  

  def generate_optionator
    copy_file "migration.rb", "db/migrate/#{migration_time}_optionator_create_options.rb"
    copy_file "option.rb", "app/models/option.rb"
  end

  def migration_time
    Time.now.strftime('%Y%m%d%H%M%S') 
  end

end  
