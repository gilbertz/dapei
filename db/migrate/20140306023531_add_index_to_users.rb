# -*- encoding : utf-8 -*-
class AddIndexToUsers < ActiveRecord::Migration
  def change
    add_index "users", "dapei_score" 
  end
end
