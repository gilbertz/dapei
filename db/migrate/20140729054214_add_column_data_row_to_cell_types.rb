# -*- encoding : utf-8 -*-
class AddColumnDataRowToCellTypes < ActiveRecord::Migration
  def change

    # example: http://gridster.net/

    add_column :cell_types, :data_row, :integer
    add_column :cell_types, :data_col, :integer
    add_column :cell_types, :data_sizex, :integer
    add_column :cell_types, :data_sizey, :integer
  end
end
