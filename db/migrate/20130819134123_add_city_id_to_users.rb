# -*- encoding : utf-8 -*-
class AddCityIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :city_id, :integer

  end
end
