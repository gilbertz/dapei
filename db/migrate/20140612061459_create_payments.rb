# -*- encoding : utf-8 -*-
class CreatePayments < ActiveRecord::Migration
  def up
    create_table :payments do |t|
      t.integer  :order_id
      t.integer  :user_id
      t.string   :out_trade_no
      t.integer  :coin_rate
      t.decimal  :amount,               precision: 10, scale: 2, default: 0.0, null: false
      t.integer  :payment_method_id
      t.integer  :state

      t.timestamps
    end
    add_index :payments, [:order_id], name: "index_payments_on_order_id"
  end

  def down
    drop_table :payments
  end
end
