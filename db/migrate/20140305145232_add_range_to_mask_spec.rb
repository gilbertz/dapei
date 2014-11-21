# -*- encoding : utf-8 -*-
class AddRangeToMaskSpec < ActiveRecord::Migration
  def change
    add_column :mask_specs, :w, :integer

    add_column :mask_specs, :h, :integer

  end
end
