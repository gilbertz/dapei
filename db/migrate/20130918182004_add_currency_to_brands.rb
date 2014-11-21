# -*- encoding : utf-8 -*-
class AddCurrencyToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :currency, :string

  end
end
