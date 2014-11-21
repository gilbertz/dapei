# -*- encoding : utf-8 -*-
class AddCNameToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :c_name, :string

  end
end
