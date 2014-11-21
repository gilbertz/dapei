# -*- encoding : utf-8 -*-
class AddColumnToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :thing_img_id, :integer
  end
end
