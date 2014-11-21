# -*- encoding : utf-8 -*-
class AddWeightToApps < ActiveRecord::Migration
  def change
    add_column :apps, :weight, :integer
    add_index :apps, :weight
  end
end
