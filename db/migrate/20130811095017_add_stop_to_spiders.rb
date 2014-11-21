# -*- encoding : utf-8 -*-
class AddStopToSpiders < ActiveRecord::Migration
  def change
      add_column :spiders, :stop, :boolean
  end
end
