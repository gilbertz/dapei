# -*- encoding : utf-8 -*-
class AddDescToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :desc, :string, :default => ""
  end
end
