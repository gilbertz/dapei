class Redpack < ActiveRecord::Base
  attr_accessible :action_remark, :action_title, :ibeacon_id, :max, :min, :suc_url, :fail_url, :sender_name, :wishing
end
