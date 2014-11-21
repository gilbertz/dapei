# -*- encoding : utf-8 -*-
class AddMatterCropToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :matter_crop, :string
  end
end
