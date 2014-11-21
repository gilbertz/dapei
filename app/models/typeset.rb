# -*- encoding : utf-8 -*-
class Typeset < ActiveRecord::Base

  has_many :set_cells

  belongs_to :typeset_type




end
