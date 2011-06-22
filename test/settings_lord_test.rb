require 'test_helper'

class SettingsLordTest < ActiveSupport::TestCase

  def setup
    Setting.delete_all
    SettingsLord.meta_option_collection.instance_variable_set :@collection, []
  end

  test "checking and maintaining meta options" do
    assert_raise Exception do
      Setting.send :define_options do |cfg|
        cfg.option :as_frozen => 1
      end
    end

    assert_raise Exception do
      Setting.send :define_options do |cfg|
        cfg.option :storage => :unknown
      end
    end

    assert_raise Exception do
      Setting.send :define_options do |cfg|
        cfg.option :cast => [1,2,3]
      end
    end

    assert_raise Exception do
      Setting.send :define_options do |cfg|
        cfg.option :as_boolean => true, :default => 2
      end
    end

    assert_raise Exception do
      Setting.send :define_options do |cfg|
        cfg.option :default => [1,2,3]
      end
    end

  end

  test "should not duplicate virtual meta options" do
    collection = SettingsLord.meta_option_collection.collection
    start_size = collection.size

    Setting.send :define_options do |cfg|
      cfg.name
    end
    assert collection.size == start_size + 1

    Setting.send :define_options do |cfg|
      cfg.anothet_name
    end
    assert collection.size == start_size + 2

    Setting.send :define_options do |cfg|
      cfg.name
    end
    assert collection.size == start_size + 2
  end

  test "should get right value" do
    Setting.send :define_options do |cfg|
      cfg.number :default => 10
    end

    assert Setting.number == 10
  end

  test "automatic casting" do
    Setting.send :define_options do |cfg|
      cfg.a :default => 10
      cfg.b :default => '10'
    end
    
    assert Setting.a == 10
    assert Setting.b == '10'
  end

  test "casting" do
    Setting.send :define_options do |cfg|
      cfg.number :default => 10, :cast => :to_s
    end

    assert Setting.number == "10"

    Setting.send :define_options do |cfg|
      cfg.number :default => 10, :cast => lambda {|value| value.to_s << "!!!"}
    end

    assert Setting.number == "10!!!"
  end

  test "set option" do
    Setting.send :define_options do |cfg|
      cfg.number :default => 10
    end

    Setting.number = 20
    assert Setting.number == 20
  end

  test "frozen options" do
    Setting.send :define_options do |cfg|
      cfg.number :default => 10, :as_frozen => true
    end

    assert_raise NoMethodError do
      Setting.number = 20
    end
  end

  test 'in-memory options' do
    Setting.send :define_options do |cfg|
      cfg.in_memory_number :default => 10, :storage => :memory
    end

    assert Setting.find_by_name('in_memory_number') == nil && Setting.in_memory_number == 10

    Setting.in_memory_number = 30
    assert Setting.in_memory_number == 30
  end

  test 'as_boolean options' do
    Setting.send :define_options do |cfg|
      cfg.bool_value :default => true, :as_boolean => true
    end

    assert Setting.find_by_name('bool_value').value == '1' && Setting.bool_value.is_a?(TrueClass)

    Setting.bool_value = false
    assert Setting.find_by_name('bool_value').value == '0' && Setting.bool_value.is_a?(FalseClass)
  end

  test 'accepted_values options' do
    Setting.send :define_options do |cfg|
      cfg.some_super_option :default => 0, :accepted_values => 0..3
      cfg.string_super_option :default => "en", :accepted_values => ['ru','en','by']
    end

    assert_raise Exception do
      Setting.some_super_option = 4
    end
    assert (Setting.some_super_option = 1) && (Setting.some_super_option == 1)

    assert_raise Exception do
      Setting.string_super_option = 'us'
    end
    assert Setting.string_super_option = 'ru'
  end

  test "regexp accepted values" do
    Setting.send :define_options do |cfg|
      cfg.some_option :default => 0, :accepted_values => /abc/
    end

    assert Setting.some_option = 'abc'
    assert_raise Exception do
      Setting.some_option = 'abd'
    end
  end

  test 'namespaces get' do
    Setting.send :define_options,:view do |cfg|
      cfg.nested_number :default => 10
    end

    assert Setting.view.is_a? SettingsLord::Reflector
    assert Setting.view.nested_number == 10
  end

  test 'namespace set' do
    Setting.send :define_options,:view do |cfg|
      cfg.nested_number :default => 10
    end
    
    Setting.view.nested_number = 20
    assert Setting.view.nested_number == 20
  end

end
