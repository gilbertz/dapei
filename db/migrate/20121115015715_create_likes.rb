# -*- encoding : utf-8 -*-
class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.boolean  "positive",                              :default => true
      t.integer  "target_id"
      t.integer  "user_id"
      t.string   "target_type",             :limit => 60,                   :null => false

    end

    add_index :likes, :target_type
    add_index :likes, :target_id
    add_index :likes, :user_id
    add_index :likes, [:target_type, :target_id]
  end

  def self.down
    drop_table :likes
  end
end
