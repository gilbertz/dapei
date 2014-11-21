# -*- encoding : utf-8 -*-
class AddFieldToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :pcolor, :text

    add_column :spiders, :psize, :text

    add_column :spiders, :porigin_price, :text

    add_column :spiders, :pshow_img, :text

    add_column :spiders, :pcode, :text

  end
end
