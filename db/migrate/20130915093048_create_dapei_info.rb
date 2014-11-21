# -*- encoding : utf-8 -*-
class CreateDapeiInfo < ActiveRecord::Migration
  def up
    create_table :dapei_infos do |t|
      t.integer :user_id
      t.integer :did
      t.integer :basedon_tid
      t.string :title
      t.text :description
      t.integer :category_id
      t.string :post_share
      t.string :spec_uuid
      t.timestamps
    end
  end

  def down
    drop_table :dapei_infos
  end
end
