# -*- encoding : utf-8 -*-
class AddStoreCountToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :pstore_count, :text

    add_column :spiders, :psold_count, :text

  end
end
