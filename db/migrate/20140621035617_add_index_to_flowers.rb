# -*- encoding : utf-8 -*-
class AddIndexToFlowers < ActiveRecord::Migration
  def change
    add_index :flowers, :is_lucky
    add_index :flowers, :created_at
  end
end
