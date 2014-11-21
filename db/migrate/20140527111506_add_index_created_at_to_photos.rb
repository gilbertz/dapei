# -*- encoding : utf-8 -*-
class AddIndexCreatedAtToPhotos < ActiveRecord::Migration
  def change
    add_index  :photos, :created_at
  end
end
