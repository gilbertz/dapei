# -*- encoding : utf-8 -*-
class AddStartPagesToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :start_page_4, :string

    add_column :spiders, :start_page_5, :string

    add_column :spiders, :start_page_6, :string

    add_column :spiders, :start_page_7, :string

    add_column :spiders, :start_page_8, :string

    add_column :spiders, :start_page_11, :string

    add_column :spiders, :start_page_12, :string

    add_column :spiders, :start_page_13, :string

    add_column :spiders, :start_page_14, :string

  end
end
