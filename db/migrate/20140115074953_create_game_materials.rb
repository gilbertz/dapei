# -*- encoding : utf-8 -*-
class CreateGameMaterials < ActiveRecord::Migration
  def change
    create_table :game_materials do |t|
      t.text     :html
      t.string   :name
      t.string   :slug
      t.string   :wx_appid
      t.string   :wx_tlimg 
      t.string   :wx_url 
      t.string   :wx_title 
      t.string   :wxdesc  

      t.timestamps
    end
  end
end
