# -*- encoding : utf-8 -*-
class CreateTshows < ActiveRecord::Migration
  def change
    create_table :tshows do |t|
      t.date :show_date
      t.string :city
      t.string :author
      t.text :content
      t.integer :brand_id
      t.string :season
      t.integer :tshow_spider_id

      t.timestamps
    end
  end
end
