# -*- encoding : utf-8 -*-
class AddIndexToLabel < ActiveRecord::Migration
  def change
    add_index :labels, :name
  end
end
