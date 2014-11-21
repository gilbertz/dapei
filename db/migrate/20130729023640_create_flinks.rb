# -*- encoding : utf-8 -*-
class CreateFlinks < ActiveRecord::Migration
  def change
    create_table :flinks do |t|
      t.string :name
      t.string :link

      t.timestamps
    end
  end
end
