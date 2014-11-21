# -*- encoding : utf-8 -*-
class AddThumbUrlToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :thumb_url, :string, :default => ""
  end
end
