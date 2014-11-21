# -*- encoding : utf-8 -*-
class CreateDescTags < ActiveRecord::Migration
  def up
    create_table :desc_tags do |t|
      t.integer :category_id
      t.integer :tag_id
      t.string :desc
      t.timestamps
    end
  end

  def down
    drop_table :desc_tags
  end
end
