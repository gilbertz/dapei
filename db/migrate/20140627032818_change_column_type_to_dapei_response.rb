# -*- encoding : utf-8 -*-
class ChangeColumnTypeToDapeiResponse < ActiveRecord::Migration
  def up
     change_column :dapei_responses, :dapei_id, :string
  end

  def down
  end
end
