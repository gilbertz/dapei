# -*- encoding : utf-8 -*-
class AddDescToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :desc, :text, :default => ""
  end
end
