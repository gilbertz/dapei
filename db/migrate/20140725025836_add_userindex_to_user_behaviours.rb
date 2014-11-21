# -*- encoding : utf-8 -*-
class AddUserindexToUserBehaviours < ActiveRecord::Migration
  def change
    add_index :user_behaviours, :user_id
  end
end
