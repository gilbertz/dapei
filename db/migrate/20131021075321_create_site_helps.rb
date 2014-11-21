# -*- encoding : utf-8 -*-
class CreateSiteHelps < ActiveRecord::Migration
  def change
    create_table :site_helps do |t|
      t.string :name
      t.integer :parent_id
      t.string :url
      t.text :content

      t.timestamps
    end
  end
end
