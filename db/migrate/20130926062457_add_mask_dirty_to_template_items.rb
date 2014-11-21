# -*- encoding : utf-8 -*-
class AddMaskDirtyToTemplateItems < ActiveRecord::Migration
  def change
    add_column :template_items, :mask_dirty, :integer
    add_column :template_items, :mask_id, :integer
    add_column :template_items, :display_price, :string
  end
end
