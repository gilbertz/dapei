# -*- encoding : utf-8 -*-
class AddCityIdToUserLocations < ActiveRecord::Migration
  def change
    add_column :user_locations, :city_id, :integer

  end
end
