# -*- encoding : utf-8 -*-
class AddPriorityToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :priority, :integer, :default=>0
  end
end
