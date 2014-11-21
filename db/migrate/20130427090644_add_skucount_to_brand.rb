# -*- encoding : utf-8 -*-
class AddSkucountToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :skus_count, :integer
  end
end
