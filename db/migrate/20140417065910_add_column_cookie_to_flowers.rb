# -*- encoding : utf-8 -*-
class AddColumnCookieToFlowers < ActiveRecord::Migration
  def change
    add_column :flowers, :cookie, :string
  end
end
