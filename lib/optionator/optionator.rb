module Optionator

  ACTIVE_RECORD_COLUMNS = ['name','value','klass','parent_id']

  mattr_accessor :option_creator
  mattr_accessor :meta_option_collection

  # check Option model for columns
  def self.check_active_record!
    ACTIVE_RECORD_COLUMNS.each do |column|
      unless Option.column_names.include?(column)
        raise Exception, "Column '#{column}' doesn't exists in class #{self.name}!"
      end
    end
  end

  # Objects pool
  # You can access MetaOptionCollection or OptionCreator just by calling Optionator class methods
  def self.setup_plugin!
    self.meta_option_collection ||= MetaOptionCollection.new
    self.option_creator ||= OptionCreator.new
  end

end
