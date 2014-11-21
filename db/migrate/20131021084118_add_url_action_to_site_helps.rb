# -*- encoding : utf-8 -*-
class AddUrlActionToSiteHelps < ActiveRecord::Migration
  def change
    add_column :site_helps, :url_action, :string

  end
end
