# -*- encoding : utf-8 -*-
class CreateTypesets < ActiveRecord::Migration
  def up
    create_table :typesets do |t|
      t.string :name
      t.integer :flag_type, :default => 1  #集合类型
      t.integer :is_active, :default => 0 #是否显示
      t.integer :order_no, :null => false, :default => 0  #排序
      t.timestamps
    end

    add_index :typesets, :is_active
    add_index :typesets, :order_no
  end

  def down
    drop_table :typesets
  end
end
