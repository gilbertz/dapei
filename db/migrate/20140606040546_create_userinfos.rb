# -*- encoding : utf-8 -*-
class CreateUserinfos < ActiveRecord::Migration
  def up
    create_table :userinfos do |t|
      t.integer :user_id, :null => false
      t.integer :followers_count, :default => 0
      t.integer :following_count, :default => 0
      t.timestamps
    end

    add_index :userinfos, :user_id, :unique => true

  end

  def down
    drop_table :userinfos
  end
end
