# -*- encoding : utf-8 -*-
class AddDapeiScoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dapei_score, :integer

  end
end
