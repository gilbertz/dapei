# -*- encoding : utf-8 -*-
class AddImageToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :image, :string
  end
end
