# -*- encoding : utf-8 -*-
class AddSomefeildsToTshows < ActiveRecord::Migration
  def change
    add_column :tshows, :docid, :string
    add_column :tshows, :url, :string
    add_index  :tshows, :docid
  end
end
