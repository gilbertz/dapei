# -*- encoding : utf-8 -*-
class AddByToUserActivities < ActiveRecord::Migration
  def change
    add_column :user_activities, :by, :string
  end
end
