# -*- encoding : utf-8 -*-
class AddImageThingToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :image_thing, :string

  end
end
