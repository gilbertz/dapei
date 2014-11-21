# -*- encoding : utf-8 -*-
class AddN2sToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :n2s, :boolean

  end
end
