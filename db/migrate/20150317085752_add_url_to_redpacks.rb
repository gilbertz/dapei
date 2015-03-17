class AddUrlToRedpacks < ActiveRecord::Migration
  def change
    add_column :redpacks, :suc_url, :string
    add_column :redpacks, :fail_url, :string
  end
end
