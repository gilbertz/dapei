# -*- encoding : utf-8 -*-
class AddNewAvatarUrlToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :white_avatar_url, :string

    add_column :brands, :black_avatar_url, :string

  end
end
