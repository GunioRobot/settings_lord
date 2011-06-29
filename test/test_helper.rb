require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:", :database => 'settings_test')

ActiveRecord::Schema.define(:version => 1) do
	create_table :settings, :force => true do |t|
		t.string :name
		t.text :value
		t.string :klass
		t.integer :parent_id
	end
end

class Setting < ActiveRecord::Base
end

require File.join(File.dirname(__FILE__),'..','lib','settings_lord.rb')
