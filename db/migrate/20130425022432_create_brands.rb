# -*- encoding : utf-8 -*-
class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :e_name
      t.text :des

      t.timestamps
    end
  end
end
