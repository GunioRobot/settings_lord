class SettingsLord::SettingCreator

  # OptionCreator process new option creation
  #
  # OptionCreator check conditions and defend you from some stupid options :)
  #  for example:
  #  you try to create option which can hold only true/false values ( :as_boolean => true )
  #  but in :default flag you write some integer ( :default => 100 )
  #  OptionCreator handle this situation and warn you about this.

  attr_accessor :parent
  attr_accessor :klass
  attr_accessor :meta

  def initialize
    @meta = SettingsLord.meta_settings.class # holds class for easy access to constants
    @meta_collection = SettingsLord.meta_settings # holds meta collection
  end

  # each option creates via method missing
  # 
  #   define_options :test do |option|
  #     option.super_option :default => 10 # => method_missing will be called with 'super_action' as "name" argument
  #   end
  def method_missing(name,*args,&block)
    options = args.extract_options!
    options.assert_valid_keys(@meta::VALID_KEYS)
    options = check_and_maintain_options(options)

		check_reserved_words(name)

    options[:klass] = @klass # option should know class
    options[:parent] = @parent.name.to_sym if @parent
    options[:name] = name
    
    new_meta_option = SettingsLord::MetaSetting.new(options)
    @meta_collection.add(new_meta_option)
  end

  private

  def check_and_maintain_options(options)
    check_bool_flags(options)
    check_and_setup_storage(options)
    check_accepted_values_flag(options)
    check_and_setup_cast_flag(options)
    check_default_value_flag(options)
    return options
  end

	def check_reserved_words(name)
		SettingsLord::RESERVED_REFLECTOR_WORDS.each do |word|
			if name == word
				raise Exception, "'#{word}' is reserved by SettingsLord."
			end
		end
	end

  def check_bool_flags(options)
    @meta::BOOL_KEYS.each do |key|
      if options[key] and not @meta::BOOL_CLASSES.include?(options[key].class)
        raise Exception, "TrueClass or FalseClass expected but got instance of #{options[key].class} in #{key}"
      end
    end
  end
  
  def check_and_setup_storage(options)
    options[:storage] ||= :active_record
    raise Exception, "Possible storages is -> #{@meta::POSSIBLE_STORAGES.inspect}" unless @meta::POSSIBLE_STORAGES.include?(options[:storage])
    # force setup value if storage is virtual
    options[:value] = options[:default] if options[:storage] == :virtual
  end

  def check_accepted_values_flag(options)
    if options[:accepted_values]
      raise Exception,"Possible classes for :accepted_values flag is -> #{@meta::ACCEPTED_VALUES_CLASSES.inspect}, not a #{options[:accepted_values].class}" unless @meta::ACCEPTED_VALUES_CLASSES.include?(options[:accepted_values].class)
    end
  end

  def check_and_setup_cast_flag(options)
    if options[:cast]
      raise Exception,"Possible classes for :cast flag is -> #{@meta::CAST_CLASSES}, not a #{options[:cast].class}" unless @meta::CAST_CLASSES.include?(options[:cast].class)
    end
    if options[:default] and options[:default].is_a? Fixnum and options[:cast].blank?
      options[:cast] = :to_i
    end
  end

  def check_default_value_flag(options)
    if options[:as_boolean] == true and options[:default].present? and not @meta::BOOL_CLASSES.include?(options[:default].class)
      raise Exception, 'true or false should be as default value' 
    else
      if not options[:as_boolean] and options[:default] and not @meta::DEFAULT_VALUE_CLASSES.include?(options[:default].class)
        raise Exception, "Possible classes for :default flag is -> #{@meta::DEFAULT_VALUE_CLASSES.inspect}, not a #{options[:default].class}"
      end
    end
  end


end
