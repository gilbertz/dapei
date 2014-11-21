# -*- encoding : utf-8 -*-
class AddIndexToBrands < ActiveRecord::Migration
  def change
    add_index :brands, :e_name

    add_index :brands, :c_name

  end
end
