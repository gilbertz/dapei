# -*- encoding : utf-8 -*-
class AddDescToTags < ActiveRecord::Migration
  def change
    add_column :tags, :desc, :text, :default => ""
  end
end
