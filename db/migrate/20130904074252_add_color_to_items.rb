# -*- encoding : utf-8 -*-
class AddColorToItems < ActiveRecord::Migration
  def change
    add_column :items, :color, :string

  end
end
