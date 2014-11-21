# -*- encoding : utf-8 -*-
class AddOtherFieldsToTshowSpiders < ActiveRecord::Migration
  def change
    add_column :tshow_spiders, :img_attr, :string
    add_column :tshow_spiders, :img_rule, :string
    add_column :tshow_spiders, :others, :text
  end
end
