# -*- encoding : utf-8 -*-
class AddIndexToUserBehaviours < ActiveRecord::Migration
  def change
    add_index  :user_behaviours, :request_time
  end
end
