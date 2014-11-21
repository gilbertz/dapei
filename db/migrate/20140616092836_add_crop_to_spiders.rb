# -*- encoding : utf-8 -*-
class AddCropToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :crop, :string
  end
end
