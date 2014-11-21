# -*- encoding : utf-8 -*-
class AddIosIdToApp < ActiveRecord::Migration
  def change
    add_column :apps, :ios_id, :string
  end
end
