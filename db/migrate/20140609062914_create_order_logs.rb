# -*- encoding : utf-8 -*-
class CreateOrderLogs < ActiveRecord::Migration
  def up
    create_table :order_logs do |t|
      t.integer  :order_id
      t.integer  :user_id
      t.string   :operator
      t.string   :action
      t.string   :detail

      t.timestamps
    end
    add_index :order_logs, [:order_id]
  end

  def down
    drop_table :order_logs
  end
end
