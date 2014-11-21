# -*- encoding : utf-8 -*-
class ChangeColumnToBrands < ActiveRecord::Migration
  def up
    change_column :brands, :brand_intro, :text 
  end

  def down
  end
end
