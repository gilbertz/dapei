# -*- encoding : utf-8 -*-
class AddIndexToUserActivities < ActiveRecord::Migration
  def change
    add_index "user_activities", ["user_id", "action"]
    add_index "user_activities", "user_id"
    add_index "user_activities", "object_type"
    add_index "user_activities", "action"
  end
end
