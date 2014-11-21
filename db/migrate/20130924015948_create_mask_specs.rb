# -*- encoding : utf-8 -*-
class CreateMaskSpecs < ActiveRecord::Migration
  def up
    create_table :mask_specs do |t|
      t.integer :template_item_id
      t.string :x
      t.string :y
    end
  end

  def down
    drop_table :mask_specs
  end
end
