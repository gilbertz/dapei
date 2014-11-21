# -*- encoding : utf-8 -*-
class AddAvailableToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :available, :boolean

  end
end
