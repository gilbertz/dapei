# -*- encoding : utf-8 -*-
class AddOffPercentToItems < ActiveRecord::Migration
  def change
    add_column :items, :off_percent, :integer

    add_column :items, :last_off_percent, :integer

  end
end
