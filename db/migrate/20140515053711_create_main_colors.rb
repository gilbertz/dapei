# -*- encoding : utf-8 -*-
class CreateMainColors < ActiveRecord::Migration
  def up
    create_table :main_colors do |t|
      t.string :color_value
      t.string :color_r
      t.string :color_g
      t.string :color_b
    end
  end

  def down
    drop_table :main_colors
  end
end
