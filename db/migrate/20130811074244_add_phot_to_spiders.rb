# -*- encoding : utf-8 -*-
class AddPhotToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :phot, :text

  end
end
