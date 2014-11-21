# -*- encoding : utf-8 -*-
class AddImgUrlToDapeiTag < ActiveRecord::Migration
  def change
    add_column :dapei_tags, :img_url, :string

  end
end
