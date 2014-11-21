# -*- encoding : utf-8 -*-
class AddHotToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :hot, :integer

  end
end
