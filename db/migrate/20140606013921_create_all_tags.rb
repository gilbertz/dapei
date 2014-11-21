# -*- encoding : utf-8 -*-
class CreateAllTags < ActiveRecord::Migration
  def up
    create_table :all_tags do |t|
      t.string :name
      t.text :similar
      t.integer :weight, :default => 0
      t.timestamps
    end
  end

  def down
    drop_table :all_tags
  end
end
