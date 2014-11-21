# -*- encoding : utf-8 -*-
class ChangeIsgirlInUser < ActiveRecord::Migration
  def up
    change_column :users, :is_girl, :string
  end

  def down
    change_column :users, :is_girl, :boolean
  end
end
