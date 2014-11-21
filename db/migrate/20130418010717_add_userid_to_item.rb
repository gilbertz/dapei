# -*- encoding : utf-8 -*-
class AddUseridToItem < ActiveRecord::Migration
  def change
    add_column :items, :user_id, :integer
  end
end
