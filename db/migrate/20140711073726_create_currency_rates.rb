# -*- encoding : utf-8 -*-
class CreateCurrencyRates < ActiveRecord::Migration
  def change
    create_table :currency_rates do |t|
      t.string :name
      t.string :currency
      t.float :rate
                    
      t.timestamps
    end
  end
end
