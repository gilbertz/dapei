# -*- encoding : utf-8 -*-
class TypesetType < ActiveRecord::Base

  has_many :cell_types

  def self.for_select
    self.all.collect{|tt| [tt.mark, tt.id] }
  end

end
