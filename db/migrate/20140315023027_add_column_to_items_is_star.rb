# -*- encoding : utf-8 -*-
class AddColumnToItemsIsStar < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :is_star, :integer, :default => 0
  end
end
