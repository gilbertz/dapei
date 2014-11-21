# -*- encoding : utf-8 -*-
class ChangeNameProperty < ActiveRecord::Migration
  def up
    change_column :properties, :name, :string
  end

  def down
    change_column :properties, :name, :integer
  end
end
