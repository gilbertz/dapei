# -*- encoding : utf-8 -*-
class AddDapeisCountToMatters < ActiveRecord::Migration
  def change
    add_column :matters, :dapeis_count, :integer
  end
end
