# -*- encoding : utf-8 -*-
class Relation < ActiveRecord::Base
  belongs_to :item
  belongs_to :target ,:polymorphic => true
end
