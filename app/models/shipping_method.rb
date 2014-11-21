# -*- encoding : utf-8 -*-
class ShippingMethod < ActiveRecord::Base


  attr_accessible :name, :price, :tracking_url, :default, :state


  validates :name, presence: true
  validates :price, numericality: true
  validate  :check_default, if: Proc.new{|sm| sm.state == 0 }
  validate  :check_state,   if: Proc.new{|sm| sm.default == true }

  before_update :undock_other_default, if: Proc.new{|sm| sm.default == true }

  scope :default, -> { where(default: true)[0] }
  def invert_state
    val = self.state.eql?(0) ? 1 : 0
    self.update_attributes(state: val)
  end

  def cn_state
    {1 => '上线', 0 => '下线', nil => '下线'}[state]
  end

  def cn_default
    {true => '是', false => '否', nil => '否'}[default]
  end

  private

  # TODO
  def undock_other_default
    dsm = self.class.where(default: true)
    return if dsm.blank?
    dsm.delete_if { |sm| sm.id == self.id }
    dsm.present? && dsm.update_all(default: false)
  end

  def check_default
    errors.add(:default, :invalid) if self.default == 1
  end

  def check_state
    errors.add(:state, :invalid) if self.state == 0
  end

end
