# -*- encoding : utf-8 -*-
class CreateColors < ActiveRecord::Migration
  def up
    create_table "colors" do |t|
      t.string  "color_name"
      t.string  "color_slug"
      t.integer "color_r"
      t.integer "color_g"
      t.integer "color_b"
      t.string  "color_rgb"
      t.string  "color_16"
    end
  end

  def down
    drop_table "colors"
  end
end
