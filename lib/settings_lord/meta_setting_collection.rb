class SettingsLord::MetaSettingCollection
  
  VALID_KEYS = [:default,:accepted_values,:cast,:as_frozen,:as_boolean,:storage]
  BOOL_KEYS = [:as_frozen,:as_boolean]

  BOOL_CLASSES = [TrueClass,FalseClass]
  DEFAULT_VALUE_CLASSES = [Fixnum,String]
  ACCEPTED_VALUES_CLASSES = [Array,Range,Regexp]
  CAST_CLASSES = [Symbol,Proc]
  SET_AND_GET_KEYS = [:klass,:namespace,:name,:default_value,:new_value]

  POSSIBLE_STORAGES = [:active_record,:memory]

  attr_reader :collection # contains all MetaOption objects
  attr_reader :klasses_and_namespaces # contains classes and namespaces for fast look-up

  def initialize
    @collection = []
    @klasses_and_namespaces = {}
  end

  def add(meta_option)
    return false unless meta_option.is_a? SettingsLord::MetaSetting

    remove_if_exists(meta_option)
    fill_klasses_and_namespaces_table(meta_option)
    self.collection << meta_option
  end

  def has_klass?(klass_name)
    self.klasses_and_namespaces.keys.include?(klass_name.to_sym)
  end

  def klass_has_namespace?(klass,namespace)
    self.has_klass?(klass) and self.klasses_and_namespaces[klass].include?(namespace.to_sym)
  end

  def set_by(reflection)
    reflection.name = remove_set_tag(reflection.name)

    if meta_option = find_by_reflection(reflection)
      meta_option.update_value(reflection.new_value)
    else
      return nil
    end
  end

  def get_by(reflection)
    find_by_reflection(reflection)
  end

  def find_by_reflection(reflection)
    # we can't search without klass and name
    return nil if reflection.klass.blank? || reflection.name.blank?

    # check klass
    return nil unless has_klass?(reflection.klass)

    # check namespace if needed
    if reflection.reflect_like_namespace
      return nil unless klass_has_namespace?(reflection.klass, reflection._parent)
    end

    if reflection.reflect_like_namespace
      result = @collection.select do |entry|
        entry.klass == reflection.klass and entry.name == reflection.name and entry.parent == reflection._parent
      end
    else
      result = @collection.select do |entry|
        entry.klass == reflection.klass and entry.name == reflection.name
      end
    end
    
    return result.first
  end

  private

  # transfer :method_name= to :method_name
  def remove_set_tag(target)
    target.to_s.gsub(/=$/,'').to_sym
  end

  def remove_if_exists(target)
    self.collection.each do |source|
      self.collection.delete_if {|s| s.similar_to?(target)}
    end
  end

  def fill_klasses_and_namespaces_table(option)
    klass_name = option.formatted_klass_name
    @klasses_and_namespaces[klass_name] ||= []
    if option.respond_to? :parent
      @klasses_and_namespaces[klass_name] << option.parent
      @klasses_and_namespaces[klass_name].uniq!
    end
  end

end
