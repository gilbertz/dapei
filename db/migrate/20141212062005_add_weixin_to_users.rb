class AddWeixinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :weixin, :string
  end
end
