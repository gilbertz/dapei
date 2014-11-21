class AddIndexInfoToItem < ActiveRecord::Migration
  def change
    add_column :items, :index_info, :string
  end
end
