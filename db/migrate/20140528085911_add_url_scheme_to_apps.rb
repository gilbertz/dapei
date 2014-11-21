# -*- encoding : utf-8 -*-
class AddUrlSchemeToApps < ActiveRecord::Migration
  def change
    add_column :apps, :url_scheme, :string
  end
end
