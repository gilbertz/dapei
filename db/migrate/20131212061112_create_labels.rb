# -*- encoding : utf-8 -*-
class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.integer :sku_id
      t.string :name
      t.integer :weight

      t.timestamps
    end
  end
end
