class Ibeacon < ActiveRecord::Base
  attr_accessible :beaconid, :uid, :pv, :url, :user_id, :uv, :remark
end
