# -*- encoding : utf-8 -*-
class AddPaymentsTradeNo < ActiveRecord::Migration
  def up
    add_column :payments, :trade_no, :string
  end

  def down
    remove_column :payments, :trade_no
  end
end
