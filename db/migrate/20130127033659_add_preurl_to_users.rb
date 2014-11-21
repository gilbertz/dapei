# -*- encoding : utf-8 -*-
class AddPreurlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :preurl, :string
  end
end
