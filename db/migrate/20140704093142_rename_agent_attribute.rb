# -*- encoding : utf-8 -*-
class RenameAgentAttribute < ActiveRecord::Migration
  def change
    rename_column :spiders, :is_redirect, :is_guide
  end
end
