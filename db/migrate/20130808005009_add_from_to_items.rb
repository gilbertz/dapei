# -*- encoding : utf-8 -*-
class AddFromToItems < ActiveRecord::Migration
  def change
    add_column :items, :from, :string
    change_column :skus, :from, :string
  end
end
