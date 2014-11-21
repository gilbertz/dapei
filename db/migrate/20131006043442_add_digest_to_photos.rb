# -*- encoding : utf-8 -*-
class AddDigestToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :digest, :string
    add_index :photos, :digest
  end
end
