# -*- encoding : utf-8 -*-
class AddBrandIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :brand_id, :integer
  end
end
