# -*- encoding : utf-8 -*-
class AddVersionToUserDevices < ActiveRecord::Migration
  def change
    add_column :user_devices, :version, :string
  end
end
