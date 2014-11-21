# -*- encoding : utf-8 -*-
class AddDpImgAttrToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :dp_img_attr, :string

  end
end
