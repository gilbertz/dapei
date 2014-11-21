# -*- encoding : utf-8 -*-
class AddCategoryIdToGameMaterial < ActiveRecord::Migration
  def change
    add_column :game_materials, :category_id, :integer, after: :id
  end
end
