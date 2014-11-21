# -*- encoding : utf-8 -*-
class AddUdidToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :udid, :string
    add_index :devices, :udid
    add_index :devices, :token
    add_index :devices, :user_id
  end
end
