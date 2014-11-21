class AddIndexNewToUserActivities < ActiveRecord::Migration
  def change
     add_index "user_activities", ["object_type", "object"], :name => "index_user_activities_report" 
  end
end
