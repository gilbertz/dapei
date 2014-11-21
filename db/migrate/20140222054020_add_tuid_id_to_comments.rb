# -*- encoding : utf-8 -*-
class AddTuidIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :tuid, :integer

  end
end
