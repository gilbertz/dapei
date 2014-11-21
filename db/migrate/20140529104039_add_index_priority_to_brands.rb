# -*- encoding : utf-8 -*-
class AddIndexPriorityToBrands < ActiveRecord::Migration
  def change
    add_index :brands, :priority
  end
end
