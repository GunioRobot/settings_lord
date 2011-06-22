require 'test_helper'

class OptionatorTest < ActiveSupport::TestCase

  def setup
    Option.delete_all
    Optionator.meta_option_collection.instance_variable_set :@collection, []
  end

  test "checking and maintaining meta options" do
    assert_raise Exception do
      Option.send :define_options do |cfg|
        cfg.option :as_frozen => 1
      end
    end

    assert_raise Exception do
      Option.send :define_options do |cfg|
        cfg.option :storage => :unknown
      end
    end

    assert_raise Exception do
      Option.send :define_options do |cfg|
        cfg.option :cast => [1,2,3]
      end
    end

    assert_raise Exception do
      Option.send :define_options do |cfg|
        cfg.option :as_boolean => true, :default => 2
      end
    end

    assert_raise Exception do
      Option.send :define_options do |cfg|
        cfg.option :default => [1,2,3]
      end
    end

  end

  test "should not duplicate virtual meta options" do
    collection = Optionator.meta_option_collection.collection
    start_size = collection.size

    Option.send :define_options do |cfg|
      cfg.name
    end
    assert collection.size == start_size + 1

    Option.send :define_options do |cfg|
      cfg.anothet_name
    end
    assert collection.size == start_size + 2

    Option.send :define_options do |cfg|
      cfg.name
    end
    assert collection.size == start_size + 2
  end

  test "should get right value" do
    Option.send :define_options do |cfg|
      cfg.number :default => 10
    end

    assert Option.number == 10
  end

  test "automatic casting" do
    Option.send :define_options do |cfg|
      cfg.a :default => 10
      cfg.b :default => '10'
    end
    
    assert Option.a == 10
    assert Option.b == '10'
  end

  test "casting" do
    Option.send :define_options do |cfg|
      cfg.number :default => 10, :cast => :to_s
    end

    assert Option.number == "10"

    Option.send :define_options do |cfg|
      cfg.number :default => 10, :cast => lambda {|value| value.to_s << "!!!"}
    end

    assert Option.number == "10!!!"
  end

  test "set option" do
    Option.send :define_options do |cfg|
      cfg.number :default => 10
    end

    Option.number = 20
    assert Option.number == 20
  end

  test "frozen options" do
    Option.send :define_options do |cfg|
      cfg.number :default => 10, :as_frozen => true
    end

    assert_raise NoMethodError do
      Option.number = 20
    end
  end

  test 'in-memory options' do
    Option.send :define_options do |cfg|
      cfg.in_memory_number :default => 10, :storage => :memory
    end

    assert Option.find_by_name('in_memory_number') == nil && Option.in_memory_number == 10

    Option.in_memory_number = 30
    assert Option.in_memory_number == 30
  end

  test 'as_boolean options' do
    Option.send :define_options do |cfg|
      cfg.bool_value :default => true, :as_boolean => true
    end

    assert Option.find_by_name('bool_value').value == '1' && Option.bool_value.is_a?(TrueClass)

    Option.bool_value = false
    assert Option.find_by_name('bool_value').value == '0' && Option.bool_value.is_a?(FalseClass)
  end

  test 'accepted_values options' do
    Option.send :define_options do |cfg|
      cfg.some_super_option :default => 0, :accepted_values => 0..3
      cfg.string_super_option :default => "en", :accepted_values => ['ru','en','by']
    end

    assert_raise Exception do
      Option.some_super_option = 4
    end
    assert (Option.some_super_option = 1) && (Option.some_super_option == 1)

    assert_raise Exception do
      Option.string_super_option = 'us'
    end
    assert Option.string_super_option = 'ru'
  end

  test "regexp accepted values" do
    Option.send :define_options do |cfg|
      cfg.some_option :default => 0, :accepted_values => /abc/
    end

    assert Option.some_option = 'abc'
    assert_raise Exception do
      Option.some_option = 'abd'
    end
  end

  test 'namespaces get' do
    Option.send :define_options,:view do |cfg|
      cfg.nested_number :default => 10
    end

    assert Option.view.is_a? Optionator::Reflector
    assert Option.view.nested_number == 10
  end

  test 'namespace set' do
    Option.send :define_options,:view do |cfg|
      cfg.nested_number :default => 10
    end
    
    Option.view.nested_number = 20
    assert Option.view.nested_number == 20
  end

end
