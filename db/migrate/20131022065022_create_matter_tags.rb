# -*- encoding : utf-8 -*-
class CreateMatterTags < ActiveRecord::Migration
  def up
  	create_table :matter_tags do |t|
  		t.string :tag_name
  		t.string :tag_slug
  		t.timestamps
  	end
  end

  def down
  	drop_table :matter_tags
  end
end
