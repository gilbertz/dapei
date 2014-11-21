# -*- encoding : utf-8 -*-
class ModIndexToTshows < ActiveRecord::Migration
  def change
    remove_index :tshows, :docid
    add_index    :tshows, :docid, :unique => true
  end

end
