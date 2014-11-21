# -*- encoding : utf-8 -*-
class CreateSizeTypes < ActiveRecord::Migration
  def change
    create_table :size_types do |t|
      t.string :name
    end
  end
end
