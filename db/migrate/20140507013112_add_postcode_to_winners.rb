# -*- encoding : utf-8 -*-
class AddPostcodeToWinners < ActiveRecord::Migration
  def change
    add_column :winners, :postcode, :string
  end
end
