# -*- encoding : utf-8 -*-
class ChangeLabelProperty < ActiveRecord::Migration
  def change
    remove_column :labels, :sku_id
    create_table :skus_labels do |t|
      t.belongs_to :sku
      t.belongs_to :label
    end
  end

end
