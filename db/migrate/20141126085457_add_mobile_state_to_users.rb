class AddMobileStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_state, :integer
  end
end
