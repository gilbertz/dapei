# -*- encoding : utf-8 -*-
class AddSynonymToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :synonym, :string

  end
end
