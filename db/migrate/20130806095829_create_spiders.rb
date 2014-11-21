# -*- encoding : utf-8 -*-
class CreateSpiders < ActiveRecord::Migration
  def change
    create_table :spiders do |t|
      t.string :brand
      t.string :product_page
      t.string :next_page
      t.string :ptitle
      t.string :pprice
      t.string :pdesc
      t.string :pimgs
      t.string :others

      t.timestamps
    end
  end
end
