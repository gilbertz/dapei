# -*- encoding : utf-8 -*-
class AddShowPageToTshowSpider < ActiveRecord::Migration
  def change
    add_column :tshow_spiders, :show_page, :text
  end
end
