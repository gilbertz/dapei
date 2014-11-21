# -*- encoding : utf-8 -*-
class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :back_url
      t.string :click_url
      t.string :dev_name
      t.string :desc
      t.string :panel_small
      t.string :app_type
      t.string :name
      t.string :panel_large
      t.string :icon_url
      t.string :bannel_small
      t.string :banner_large
      t.string :show_cb_url
      t.string :banner_middle
      t.integer :source_type
      t.boolean :on

      t.timestamps
    end
  end
end
