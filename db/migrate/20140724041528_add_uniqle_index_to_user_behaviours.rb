# -*- encoding : utf-8 -*-
class AddUniqleIndexToUserBehaviours < ActiveRecord::Migration
  def change
    add_index :user_behaviours, [:ip_address, :request_url, :request_time], :unique=>true, :name=>"user_behaviours_ipurl"
  end
end
