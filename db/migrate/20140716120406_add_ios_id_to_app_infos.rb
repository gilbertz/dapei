# -*- encoding : utf-8 -*-
class AddIosIdToAppInfos < ActiveRecord::Migration
  def change
    add_column :app_infos, :ios_id, :string
  end
end
