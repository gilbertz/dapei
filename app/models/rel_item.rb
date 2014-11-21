# -*- encoding : utf-8 -*-
class RelItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :dapei

  validates :item_id, :presence => true
  validates :dapei_id, :presence => true

end
