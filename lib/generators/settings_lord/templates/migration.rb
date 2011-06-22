class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :name
      t.text :value
      t.string :klass
      t.integer :parent_id
    end
  end

  def self.down
    drop_table :settings
  end
end
