class SettingsLord::MetaOption

  def initialize(*args)
    setup_attributes!(args)
    setup_active_record_object!
  end

  def similar_to?(target)
    if target.respond_to? :parent
      @name == target.name && @klass == target.klass && @parent == target.parent
    else
      @name == target.name && @klass == target.klass
    end
  end

  def update_value(new_value)
    raise NoMethodError if @as_frozen == true
    
    case @accepted_values
    when Range, Array
      raise Exception unless @accepted_values.include?(new_value)
    when Regexp
      raise Exception unless !!(new_value.match(@accepted_values))
    end

    case @storage
    when :active_record
      record = Setting.find(@active_record_id)
      if @as_boolean
        bool = !!new_value ? '1' : '0'
        record.update_attribute :value, bool
      else
        record.update_attribute :value, new_value
      end
    when :memory
      if @as_boolean
        @value = !!new_value
      else
        @value = new_value
      end
    end
  end
  
  def get_value
    cast_value(extract_data,@cast)
  end

  def formatted_klass_name
    @klass.to_s.underscore.to_sym
  end

  def setup_attributes!(args)
    options = args.extract_options!

    options.each do |key,value|
      self.class.send :attr_accessor, key
      self.send "#{key.to_s}=", value
    end

    @klass = formatted_klass_name
  end

  protected 

  def setup_active_record_object!
    if @storage == :active_record
     
      # find or create object
      if @parent
        parent_record = Setting.find_parent_by_namespace(@parent,@klass)
        record = Setting.find_or_create_by_klass_and_name_and_parent_id(@klass,@name,parent_record.id)
      else
        record = Setting.find_or_create_by_klass_and_name(@klass,@name)
      end

      # setup value if needed
      if record.value.nil?
        if @as_boolean
          bool_value = (!!@default ? '1' : '0')
          record.update_attribute :value, bool_value
        else
          record.update_attribute :value, @default
        end
      end
      
      # hold acrive record id to fast search
      self.class.send :attr_accessor, :active_record_id
      @active_record_id = record.id
    end
  end

  def cast_value(value,cast_method = nil)
    case cast_method
    when Symbol
      value.send(cast_method)
    when Proc
      cast_method.call(value)
    else
      value
    end
  end

  def extract_data
     result = case @storage
              when :active_record
                Setting.find(@active_record_id).value || @default
              when :memory
                @value || @default
              end

    if @as_boolean
      result = result.to_i > 0 ? true : false
    end

    return result
  end



end
