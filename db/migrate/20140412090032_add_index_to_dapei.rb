# -*- encoding : utf-8 -*-
class AddIndexToDapei < ActiveRecord::Migration
  def change
    add_index "items", "level"
    add_index "items", "deleted"
    add_index "items", "user_id"
    add_index "items", ["user_id", "level", "category_id", "deleted"]
  end
end
