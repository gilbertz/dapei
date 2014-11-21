# -*- encoding : utf-8 -*-
class AddDisplayNameToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :display_name, :string

  end
end
