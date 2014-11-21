# -*- encoding : utf-8 -*-
class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.string :price
      t.string :discount
      t.string :display_area
      t.timestamps
    end
  end
end
