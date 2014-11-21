# -*- encoding : utf-8 -*-
class AddDeletedToItems < ActiveRecord::Migration
  def change
    add_column :items, :deleted, :boolean

  end
end
