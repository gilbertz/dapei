class AddColumnBaseUrlForItems < ActiveRecord::Migration
  def up
    add_column :items,:base_url ,:string
  end

  def down
    remove_column :items ,:base_url
  end
end
