# -*- encoding : utf-8 -*-
class CreateTypesetTypes < ActiveRecord::Migration
  def up
    create_table :typeset_types do |t|
      t.string :mark
      t.timestamps
    end
  end

  def down
    drop_table :typeset_types
  end
end
