# -*- encoding : utf-8 -*-
class CreateFlowers < ActiveRecord::Migration
  def up
    create_table :flowers do |t|
      t.integer :user_id
      t.integer :lucky_code, :default => 0, :null => false
      t.integer :is_lucky, :null => false, :default => 0
      t.timestamps
    end

    add_index :flowers, :user_id
  end

  def down
    drop_table :flowers
  end
end
