# -*- encoding : utf-8 -*-
class ChangeTshowSpidersShowdateType < ActiveRecord::Migration
  def change
    change_column :tshow_spiders, :show_date, :string
  end
end
