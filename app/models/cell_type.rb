# -*- encoding : utf-8 -*-
class CellType < ActiveRecord::Base


  default_scope -> { order("type_num asc")}

  belongs_to :typeset_type
  has_many :set_cells

  Base_width = 190
  Base_height = 122
  Base_margin = 10


  def width
    self.data_sizex.to_i * Base_width + ((self.data_sizex.to_i - 1) * Base_margin)
  end

  def height
    self.data_sizey.to_i * Base_height + ((self.data_sizey.to_i - 1) * Base_margin)
  end

  def typeset_type_mark
    self.typeset_type.mark
  end

end
