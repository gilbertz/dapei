# -*- encoding : utf-8 -*-
class AddStartPageToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :start_page, :string

  end
end
