class SettingsLord::Reflector
  # reflector hold klass/namespace information and reflect on name

  attr_accessor :name,:klass,:new_value,:_reflect_like_namespace,:_parent

  def initialize(*args)
    setup_instance_variables!(args)
  end

  # method missing will be called only when we return Reflector object
  # this is default case when user attempt to nested option (option with namespace)
  # for example:
  #
  #   Option.view.default_path
  #
  # view method will return Reflecor object
  #
  #   puts Option.view.class # => Optionator::Reflector
  #
  # default_path method will touch this method missing
  # 
  # when we return Reflector object this object already get klass and namespace information
  # we only need to setup called method name and some extra arguments
  def method_missing(called_name,*args,&block)
    @name = called_name.to_sym
    @new_value = args.first

    result = self.reflect

    if result.is_a? SettingsLord::MetaSetting
      return result.get_value
    # for setters
    elsif result.present?
      return result
    # for others
    else
      return nil
    end
  end

  # search for proper MetaOption in MetaOptionCollection and get/set needed value
  def reflect()
    should_search = @meta.has_klass?(@klass) or @meta.klass_has_namespace?(@klass,@name)
    return nil unless should_search

    if is_getter?
      return create_sub_reflection if should_create_sub_reflection?
      return @meta.get_by(self)
    else
      return @meta.set_by(self)
    end
  end

  def should_create_sub_reflection?
    @_reflect_like_namespace == false and @meta.klass_has_namespace?(@klass,@name)
  end

  def create_sub_reflection
    reflection = self.dup
    reflection._reflect_like_namespace = true
    reflection._parent = reflection.name.to_sym
    reflection.name = nil
    return reflection
  end

  def is_getter?
    not @name.to_s.end_with?('=')
  end

  def default_value_called?
    !!@name.to_s.match(/[a-zA-Z0-9]_default_value/) 
  end

  def remove_default_value_tag_from_string
    @name.to_s.gsub(/_default_value/,'').to_sym 
  end

  private

  # @name/@_parent/@klass should always be represented as Symbol
  def setup_instance_variables!(args)
    args = args.extract_options!
    @name = args[:name].to_sym
    @new_value = args[:new_value]
    @klass = args[:klass]
    @klass = args[:klass].model_name.underscore.to_sym if @klass.is_a? Class
    @_reflect_like_namespace = args[:reflect_like_namespace] || false
    @meta = SettingsLord.meta_settings
  end

end
