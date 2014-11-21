class AddDapeiInfoFlagToItem < ActiveRecord::Migration
  def change
    add_column :items, :dapei_info_flag, :integer
  end
end
