# -*- encoding : utf-8 -*-
class AddIndexToDapeis < ActiveRecord::Migration
  def change
    add_index "items", ["level", "category_id"]
  end
end
