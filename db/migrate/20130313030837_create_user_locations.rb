# -*- encoding : utf-8 -*-
class CreateUserLocations < ActiveRecord::Migration
  def change
    create_table :user_locations do |t|
      t.integer :user_id
      t.string :jindu
      t.string :weidu

      t.timestamps
    end
  end
end
