# -*- encoding : utf-8 -*-
class AddRequestTypeToUserBehaviours < ActiveRecord::Migration
  def change
    add_column :user_behaviours, :request_method, :string
  end
end
