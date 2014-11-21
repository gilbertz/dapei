# -*- encoding : utf-8 -*-
class CreateTshowSpiders < ActiveRecord::Migration
  def change
    create_table :tshow_spiders do |t|
      t.boolean :stop
      t.integer :template_id
      t.text :start_page
      t.boolean :is_template
      t.text :images_start_page
      t.date :show_date
      t.string :city
      t.string :author
      t.text :content
      t.integer :brand_id
      t.string :season

      t.timestamps
    end
  end
end
