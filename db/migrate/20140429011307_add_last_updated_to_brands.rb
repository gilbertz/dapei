# -*- encoding : utf-8 -*-
class AddLastUpdatedToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :last_updated, :datetime
  end
end
