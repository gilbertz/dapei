# -*- encoding : utf-8 -*-
class CreateAppInfos < ActiveRecord::Migration
  def change
    create_table :app_infos do |t|
      t.string :code
      t.string :version
      t.string :ios_version
      t.string :ios_app_url
      t.text :feature
      t.string :download_url
      t.string :app_name
      t.boolean :active

      t.timestamps
    end
  end
end
