# -*- encoding : utf-8 -*-
class AddCategoryIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :categroy_id, :integer

  end
end
