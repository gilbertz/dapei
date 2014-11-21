# -*- encoding : utf-8 -*-
class ChangeNameIndexForUsers < ActiveRecord::Migration
  def change 
    remove_index  :users, :name
    add_index :users, :name
  end

end
