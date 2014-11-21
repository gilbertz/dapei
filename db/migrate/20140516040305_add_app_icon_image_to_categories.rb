# -*- encoding : utf-8 -*-
class AddAppIconImageToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :app_icon_image, :string, :default => ""
  end
end
