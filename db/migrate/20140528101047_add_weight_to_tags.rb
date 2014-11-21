# -*- encoding : utf-8 -*-
class AddWeightToTags < ActiveRecord::Migration
  def change
    add_column :tags, :weight, :integer
  end
end
