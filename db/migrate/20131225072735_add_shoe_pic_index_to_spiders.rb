# -*- encoding : utf-8 -*-
class AddShoePicIndexToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :shoe_pic_index, :integer

  end
end
