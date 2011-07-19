class SettingsLord::Reflector
  # reflector hold klass/namespace information and reflect on name

  attr_accessor :_name,:_klass,:_new_value,:_reflect_like_namespace,:_parent

  def initialize(*args)
    setup_instance_variables!(args)
  end

  # search for proper MetaOption in MetaOptionCollection and get/set needed value
  def reflect
    should_search = @meta.has_klass?(@_klass) or @meta.klass_has_namespace?(@_klass,@_name)
    return nil unless should_search

    if is_getter?
      return create_sub_reflection! if should_create_sub_reflection?
      return @meta.get_by(self)
    else
      return @meta.set_by(self)
    end
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
    @_name = called_name.to_sym
    @_new_value = args.first

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

  private

  # @name/@_parent/@klass should always be represented as Symbol
  def setup_instance_variables!(args)
    args = args.extract_options!
    @_name = args[:name].to_sym
    @_new_value = args[:new_value]
    @_klass = args[:klass]
    @_klass = args[:klass].model_name.underscore.to_sym if @_klass.is_a? Class
    @_reflect_like_namespace = args[:reflect_like_namespace] || false
    @meta = SettingsLord.meta_settings
  end

  def is_getter?
    not @_name.to_s.end_with?('=')
  end

  def create_sub_reflection!
    reflection = self.dup
    reflection._reflect_like_namespace = true
    reflection._parent = reflection._name.to_sym
    reflection._name = nil
    return reflection
  end

  def should_create_sub_reflection?
    @_reflect_like_namespace == false and @meta.klass_has_namespace?(@_klass,@_name)
  end

end
