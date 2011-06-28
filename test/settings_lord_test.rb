require 'test_helper'

class SettingsLordTest < ActiveSupport::TestCase

  def setup
    Setting.delete_all
    SettingsLord.meta_settings.instance_variable_set :@collection, []
  end

	test "should accept only boolean values" do
		assert_nothing_raised do
			Setting.settings do
				option :as_frozen => true
			end
		end

		assert_raise Exception do
			Setting.settings do
				option :as_frozen => 1
			end
    end
	end

	test "should accept only known storage" do
		assert_nothing_raised do
			Setting.settings do
				option :storage => :active_record	
				option_2 :storage => :memory
			end
		end

		assert_raise Exception do
			Setting.settings do
				option :storage => :javadoc
			end
		end
	end

	test "should accept only symbols and proc for :cast" do
    assert_raise Exception do
      Setting.settings do 
        option :cast => [1,2,3]
      end
    end

		assert_nothing_raised do
      Setting.settings do 
        option :cast => :to_f
				option_2 :cast => lambda {}
      end
		end
	end

	test "bool flag" do
    assert_raise Exception do
      Setting.settings do 
        option :as_boolean => true, :default => 2
      end
    end

		assert_nothing_raised do
			Setting.settings do
				option :as_boolean => true, :default => false
			end
		end
	end

	test "default value flag" do
    assert_raise Exception do
      Setting.settings do
        option :default => [1,2,3]
      end
    end

		assert_nothing_raised do
			Setting.settings do
				option_1 :default => "Hello"
				option_2 :default => 100
			end
		end
	end

  test "should not duplicate virtual meta options" do
    collection = SettingsLord.meta_settings.collection
    start_size = collection.size

    Setting.settings do
      name
    end
    assert collection.size == start_size + 1

    Setting.settings do 
      anothet_name
    end
    assert collection.size == start_size + 2

    Setting.settings do
      name
    end
    assert collection.size == start_size + 2
  end

  test "should get right value" do
    Setting.settings do 
      number :default => 10
    end

    assert Setting.number == 10
  end

  test "automatic casting" do
    Setting.settings do 
      a :default => 10
      b :default => '10'
    end
    
    assert Setting.a == 10
    assert Setting.b == '10'
  end

  test "casting" do
    Setting.settings do 
      number :default => 10, :cast => :to_s
    end

    assert Setting.number == "10"

    Setting.settings do 
      number :default => 10, :cast => lambda {|value| value.to_s << "!!!"}
    end

    assert Setting.number == "10!!!"
  end

  test "set option" do
    Setting.settings do 
      number :default => 10
    end

    Setting.number = 20
    assert Setting.number == 20
  end

  test "frozen options" do
    Setting.settings do 
      number :default => 10, :as_frozen => true
    end

    assert_raise NoMethodError do
      Setting.number = 20
    end
  end

  test 'in-memory options' do
    Setting.settings do 
      in_memory_number :default => 10, :storage => :memory
    end

    assert Setting.find_by_name('in_memory_number') == nil && Setting.in_memory_number == 10

    Setting.in_memory_number = 30
    assert Setting.in_memory_number == 30
  end

  test 'as_boolean options' do
    Setting.settings do
      bool_value :default => true, :as_boolean => true
    end

    assert Setting.find_by_name('bool_value').value == '1' && Setting.bool_value.is_a?(TrueClass)

    Setting.bool_value = false
    assert Setting.find_by_name('bool_value').value == '0' && Setting.bool_value.is_a?(FalseClass)
  end

  test 'accepted_values options' do
    Setting.settings do
      some_super_option :default => 0, :accepted_values => 0..3
      string_super_option :default => "en", :accepted_values => ['ru','en','by']
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
    Setting.settings do
      some_option :default => 0, :accepted_values => /abc/
    end

    assert Setting.some_option = 'abc'
    assert_raise Exception do
      Setting.some_option = 'abd'
    end
  end

  test 'namespaces get' do
    Setting.settings :view do 
      nested_number :default => 10
    end

    assert Setting.view.is_a? SettingsLord::Reflector
    assert Setting.view.nested_number == 10
  end

  test 'namespace set' do
    Setting.settings :view do
      nested_number :default => 10
    end
    
    Setting.view.nested_number = 20
    assert Setting.view.nested_number == 20
  end
end
