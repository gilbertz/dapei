# -*- encoding : utf-8 -*-
class AddBrandIdToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :brand_id, :integer

  end
end
