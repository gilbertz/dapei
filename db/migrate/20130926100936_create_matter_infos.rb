# -*- encoding : utf-8 -*-
class CreateMatterInfos < ActiveRecord::Migration
  def up
    create_table :matter_infos do |t|
      t.integer :matter_id
      t.string :w
      t.string :paid_url
      t.string :thing_id
      t.string :masking_policy
      t.string :brand_id
      t.string :oh
      t.string :h
      t.string :displayurl
      t.string :url
      t.string :object_id
      t.string :host_id
      t.string :object_class
      t.string :seo_title
      t.string :title
      t.string :ow
      t.timestamps
    end
  end

  def down
    drop_table :matter_infos
  end
end
