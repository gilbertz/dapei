# -*- encoding : utf-8 -*-
class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.string :titlle
      t.text :desc
      t.text :condition
      t.integer :policy_type

      t.timestamps
    end
  end
end
