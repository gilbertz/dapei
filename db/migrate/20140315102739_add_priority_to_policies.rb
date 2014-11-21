# -*- encoding : utf-8 -*-
class AddPriorityToPolicies < ActiveRecord::Migration
  def change
    add_column :policies, :priority, :text

  end
end
