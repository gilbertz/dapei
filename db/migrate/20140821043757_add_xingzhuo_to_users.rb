# -*- encoding : utf-8 -*-
class AddXingzhuoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :xingzuo, :string
  end
end
