# -*- encoding : utf-8 -*-
class CreateOrderMasks < ActiveRecord::Migration
  def up
    create_table :order_marks do |t|
      t.integer :order_id
      t.integer :brand_id
      t.integer :user_id
      t.text :mark
      t.timestamps
    end
  end

  def down
    drop_table :order_marks
  end
end
