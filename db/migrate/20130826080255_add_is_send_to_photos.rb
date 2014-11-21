# -*- encoding : utf-8 -*-
class AddIsSendToPhotos < ActiveRecord::Migration
  def change
    #是否已经被推荐到搭配素材
    add_column :photos, :is_send, :boolean, :default => 0
  end
end
