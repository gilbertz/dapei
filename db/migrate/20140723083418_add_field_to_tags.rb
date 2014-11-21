# -*- encoding : utf-8 -*-
class AddFieldToTags < ActiveRecord::Migration
  def change
    add_column :tags, :img, :string
    add_column :tags, :parent_id, :integer
    add_column :tags, :show_index, :integer
    add_column :tags, :active, :boolean
  end
end
