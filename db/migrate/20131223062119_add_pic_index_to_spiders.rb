# -*- encoding : utf-8 -*-
class AddPicIndexToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :pic_index, :integer

  end
end
