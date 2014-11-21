# -*- encoding : utf-8 -*-
class CreateCrawlerTemplates < ActiveRecord::Migration
  def change
    create_table :crawler_templates do |t|
      t.string :t
      t.string :brand_name
      t.integer :brand_id
      t.string :template
      t.string :pattern
      t.integer :skus_count
      t.boolean :status
      t.integer :last_skus_count
      t.string :source

      t.timestamps
    end
  end
end
