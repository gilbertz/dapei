# -*- encoding : utf-8 -*-
class AddDisposeCountToItem < ActiveRecord::Migration
  def change
    add_column :items, :dispose_count, :integer

  end
end
