# -*- encoding : utf-8 -*-
class AddShowFreightToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :is_show_freight, :boolean
  end
end
