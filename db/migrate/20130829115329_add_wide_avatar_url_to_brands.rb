# -*- encoding : utf-8 -*-
class AddWideAvatarUrlToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :wide_avatar_url, :string

  end
end
