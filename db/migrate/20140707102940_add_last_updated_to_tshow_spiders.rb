# -*- encoding : utf-8 -*-
class AddLastUpdatedToTshowSpiders < ActiveRecord::Migration
  def change
    add_column :tshow_spiders, :last_updated, :datetime
  end
end
