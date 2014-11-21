# -*- encoding : utf-8 -*-
class AddDomainToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :domain, :string

  end
end
