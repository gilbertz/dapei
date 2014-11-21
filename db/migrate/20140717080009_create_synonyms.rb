# -*- encoding : utf-8 -*-
class CreateSynonyms < ActiveRecord::Migration
  def up
    create_table :synonyms do |t|
      t.integer :category_id
      t.string :content
    end
  end

  def down
    drop_table :synonyms
  end
end
