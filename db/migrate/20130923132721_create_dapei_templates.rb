# -*- encoding : utf-8 -*-
class CreateDapeiTemplates < ActiveRecord::Migration
  def up
    create_table :dapei_templates do |t|
      t.string :user_type
      t.integer :age
      t.integer :buddyicon
      t.string :state
      t.integer :tid
      t.integer :isOwner
      t.string :viewport
      t.string :spec_uuid
      t.integer :fills
      t.string :status_msg
      t.string :country
      t.string :occupation
      t.string :description
      t.string :user_name
      t.string :user_age
      t.string :user_state
      t.integer :user_id
      t.string :title
      t.timestamps
    end
  end

  def down
    drop_table :dapei_templates
  end
end
