# -*- encoding : utf-8 -*-
class AddDpToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :dp, :boolean

  end
end
