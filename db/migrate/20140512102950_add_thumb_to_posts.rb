# -*- encoding : utf-8 -*-
class AddThumbToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :thumb, :string
  end
end
