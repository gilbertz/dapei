# -*- encoding : utf-8 -*-
class AddPimgAttrToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :pimg_attr, :string

  end
end
