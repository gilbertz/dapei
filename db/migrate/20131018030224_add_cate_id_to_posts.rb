# -*- encoding : utf-8 -*-
class AddCateIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :category_id, :integer

  end
end
