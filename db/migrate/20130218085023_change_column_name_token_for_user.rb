# -*- encoding : utf-8 -*-
class ChangeColumnNameTokenForUser < ActiveRecord::Migration
  def up
    rename_column :users, :token_authenticatable, :authentication_token
    add_index :users, :authentication_token, :unique=>true
  end

  def down
    remove_index :users, :authentication_token
    rename_column :users, :authentication_token, :token_authenticatable
  end
end
