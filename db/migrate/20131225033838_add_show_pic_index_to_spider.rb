# -*- encoding : utf-8 -*-
class AddShowPicIndexToSpider < ActiveRecord::Migration
  def change
    add_column :spiders, :show_pic_index, :integer

  end
end
