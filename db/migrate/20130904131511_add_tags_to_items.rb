# -*- encoding : utf-8 -*-
class AddTagsToItems < ActiveRecord::Migration
  def change
    add_column :items, :tags, :string

  end
end
