# -*- encoding : utf-8 -*-
class AddIsActiveForAppToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :is_active_for_app, :integer, :default => 0
  end
end
