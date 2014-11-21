# -*- encoding : utf-8 -*-
class AddPicIdexToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :bag_pic_index, :integer

    add_column :spiders, :peishi_pic_index, :integer

  end
end
