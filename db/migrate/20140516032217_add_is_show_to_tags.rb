# -*- encoding : utf-8 -*-
class AddIsShowToTags < ActiveRecord::Migration
  def change
    # now is only for app tag show
    add_column :tags, :is_show, :integer, :null => false, :default => 0
  end
end
