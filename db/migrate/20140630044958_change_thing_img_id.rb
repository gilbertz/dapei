# -*- encoding : utf-8 -*-
class ChangeThingImgId < ActiveRecord::Migration
  def up
    change_column :categories, :thing_img_id, :integer, :limit => 8
  end

  def down
  end
end
