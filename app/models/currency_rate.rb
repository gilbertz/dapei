# -*- encoding : utf-8 -*-
class CurrencyRate < ActiveRecord::Base
  attr_accessible :name, :currency, :rate
end
