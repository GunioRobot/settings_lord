module SettingsLord::ActiveRecord

  module ClassMethods
 
		def settings(namespace = nil,*args,&block)
			SettingsLord.check_active_record!
			self.send(:extend, SettingsLord::ActiveRecord::MethodMissing)

			SettingsLord.setting_creator.klass = self
			SettingsLord.setting_creator.parent = create_parent_by_namespace(namespace)
			SettingsLord.setting_creator.instance_eval &block
		end

    def create_parent_by_namespace(namespace)
      namespace ? Setting.find_or_create_by_name_and_klass_and_parent_id_and_value(namespace.to_s.underscore, self.model_name.underscore, nil, nil) : nil
    end

    def find_parent_by_namespace(namespace,klass)
      Setting.find_by_name_and_parent_id_and_klass(namespace.to_s,nil,klass)
    end

  end

  module MethodMissing
  
	def method_missing(name,*args,&block)
      result = SettingsLord::Reflector.new(:name => name, :new_value => args.first, :klass => self).reflect

      if result.is_a? SettingsLord::MetaSetting
        return result.get_value
      # for setters
      elsif result.present?
        return result
      # for others
      else
        super(name,*args,&block)
      end
    end

  end

end

