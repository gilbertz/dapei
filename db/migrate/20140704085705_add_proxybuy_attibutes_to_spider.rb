# -*- encoding : utf-8 -*-
class AddProxybuyAttibutesToSpider < ActiveRecord::Migration
  def change
    add_column :spiders, :is_agent, :boolean
    add_column :spiders, :is_redirect, :boolean    
    add_column :spiders, :freight, :float
  end
end
