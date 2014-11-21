# -*- encoding : utf-8 -*-
class AddProfileImgUrlToUser < ActiveRecord::Migration
  def change
    add_column :users, :profile_img_url, :string
  end
end
