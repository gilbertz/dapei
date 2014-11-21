# -*- encoding : utf-8 -*-
class AddMorefieldsToUserBehaviours < ActiveRecord::Migration
  def change
#    add_column :user_behaviours, :request_controller, :string
#    add_column :user_behaviours, :request_action, :string
#    add_column :user_behaviours, :request_format, :string
#    add_column :user_behaviours, :request_status, :string
    change_column :user_behaviours, :request_url, :string

    add_index :user_behaviours, [:request_url, :token, :request_time], :unique => true, :name=>"index_user_behaviours_request"
  end
end
