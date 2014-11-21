# -*- encoding : utf-8 -*-
class AddAttrToItems < ActiveRecord::Migration
  def change
    add_column :items, :level, :integer

    add_column :items, :desc, :string

  end
end
