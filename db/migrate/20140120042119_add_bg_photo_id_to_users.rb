# -*- encoding : utf-8 -*-
class AddBgPhotoIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bg_photo_id, :integer

  end
end
