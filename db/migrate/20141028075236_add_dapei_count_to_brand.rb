class AddDapeiCountToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :dapei_count, :integer
  end
end
