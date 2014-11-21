# -*- encoding : utf-8 -*-
class AddIndexToPhotos < ActiveRecord::Migration
  def change
    add_index :photos, :target_id
    add_index :photos, :target_type
  end
end
