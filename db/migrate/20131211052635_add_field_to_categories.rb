# -*- encoding : utf-8 -*-
class AddFieldToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :is_active, :boolean

    add_column :categories, :weight, :integer

  end
end
