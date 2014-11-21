class AddRecommendedToUserActivities < ActiveRecord::Migration
  def change
    add_column :user_activities, :recommended, :boolean
  end
end
