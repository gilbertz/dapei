# -*- encoding : utf-8 -*-
class CreateUserActivities < ActiveRecord::Migration
  def change
    create_table :user_activities do |t|
      t.integer :user_id
      t.string :action
      t.string :object_type
      t.string :object

      t.timestamps
    end
  end
end
