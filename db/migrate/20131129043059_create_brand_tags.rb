# -*- encoding : utf-8 -*-
class CreateBrandTags < ActiveRecord::Migration
  def change
    create_table :brand_tags do |t|
      t.string :name
      t.integer :thing_image_id
      t.integer :type_id
      t.boolean :on

      t.timestamps
    end
  end
end
