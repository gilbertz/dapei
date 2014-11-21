# -*- encoding : utf-8 -*-
class SetCell < ActiveRecord::Base

  belongs_to :typeset
  belongs_to :cell_type
  belongs_to :tag


end
