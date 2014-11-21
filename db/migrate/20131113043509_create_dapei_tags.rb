# -*- encoding : utf-8 -*-
class CreateDapeiTags < ActiveRecord::Migration
  def up
    create_table :dapei_tags do |t|
      t.string :name
      t.integer :tag_type
    end
  end

  def down
    drop_table :dapei_tags
  end
end
