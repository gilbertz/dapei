# -*- encoding : utf-8 -*-
class CreateCarts < ActiveRecord::Migration
  def up
    create_table :carts do |t|
      t.integer :user_id
      t.timestamps
    end

    add_index :carts, :user_id
  end

  def down
    drop_table :carts
  end
end
