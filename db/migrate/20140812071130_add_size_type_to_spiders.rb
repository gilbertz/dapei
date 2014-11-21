# -*- encoding : utf-8 -*-
class AddSizeTypeToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :size_types, :string
  end
end
