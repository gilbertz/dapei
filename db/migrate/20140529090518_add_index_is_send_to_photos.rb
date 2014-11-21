# -*- encoding : utf-8 -*-
class AddIndexIsSendToPhotos < ActiveRecord::Migration
  def change
    add_index :photos, :is_send
  end
end
