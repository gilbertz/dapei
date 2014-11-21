# -*- encoding : utf-8 -*-
class Order < ActiveRecord::Base

  STATUS = {
      :waiting    => 11,
      :pending    => 22,
      :confirmed  => 33,
      :delivered  => 44,
      :completed  => 55,
      :canceled   => 66,
      :expired    => 77,
      :removed    => 88
  }
  STATU = STATUS

  STATUS_ARG = {
      waiting:        "未付款",
      pending:        "待处理",
      confirmed:      "已确认",
      delivered:      "已发货",
      completed:      "完成",
      canceled:       "取消",
      expired:        "过期",
      removed:        "删除"
  }

  validate  :check_state,      on: :update

  has_many :line_items
  belongs_to :user
  belongs_to :ship_address
  has_many   :logs, class_name: "OrderLog", dependent: :delete_all
  has_one :payment, autosave: true, dependent: :destroy

  has_one :shipment

  attr_accessor :intermediate



  scope :active, -> { where(:is_delete => 0) }
  scope :deleted, -> { where(:is_delete => 1) }
  #scope
  scope :sort_time, -> { order('id desc') }
  scope :waiting,   -> { where(state: STATUS[:waiting]).sort_time }
  scope :paid,      -> { where(state: [22,33,44,55]).sort_time }
  scope :pending,   -> { where(state: STATUS[:pending]).sort_time }
  scope :confirmed, -> { where(state: STATUS[:confirmed]).sort_time }
  scope :delivered, -> { where(state: STATUS[:delivered]).sort_time }
  scope :completed, -> { where(state: STATUS[:completed]).sort_time }
  scope :canceled,  -> { where(state: STATUS[:canceled]).sort_time }
  scope :expired,   -> { where(state: STATUS[:expired]).sort_time }
  scope :removed,   -> { where(state: STATUS[:removed]).sort_time }

  # pay type 1支付宝支付  2微信支付

  #验证前回调
  before_validation :generate_order_number, :set_state,  on: :create

  before_save :set_price


  def invert_status; STATU.invert[state] end
  def cn_status; self.cn_status_word[invert_status] end

  def cn_status_word
    arg = {
        waiting:        "未付款",
        pending:        "待处理",
        confirmed:      "已确认",
        delivered:      "已发货",
        completed:      "完成",
        canceled:       "取消",
        expired:        "过期",
        removed:        "删除"
    }
  end


  def confirm(operator=nil)
    self.logs.build(action: "您的订单已确认", operator: operator)
    self.update_attributes(intermediate: STATUS[:confirmed])
  end

  def delivery(operator=nil)
    self.logs.build(action: "您的订单已发货", operator: operator)
    self.update_attributes(intermediate: STATUS[:delivered])
  end

  def complete(operator=nil)
    self.logs.build(action: "您的订单已完成", operator: operator || '完成')
    self.update_attributes(intermediate: STATUS[:completed])
  end

  def expire(operator=nil)
    self.logs.build(action: "您的订单已过期, 失效", operator: '系统')
    self.update_attributes(intermediate: STATUS[:expired])
  end

  def pend
    self.logs.build(action: "您的订单已付款, 请等待系统确认", operator: '客户')
    self.update_attributes(intermediate: STATUS[:pending])
  end

  def cancel(operator=nil)
    self.logs.build(action: "您的订单已取消", operator: operator || '客户')
    self.update_attributes(intermediate: STATUS[:canceled])
  end

  def remove(operator)
    self.logs.build(action: "该订单被删除", operator: operator)
    self.update_attributes(intermediate: STATUS[:removed])
  end


  def get_mark_by_brand_id(brand_id)

    om = OrderMark.where(:order_id => self.id, :brand_id => brand_id).first
    unless om.blank?
      om.mark
    else
      ""
    end

  end


  def created_at_bj
    #Beijing time zone
    (self.created_at + 8.hours).strftime("%Y-%m-%d %H:%M:%S")
  end

  private

  #按品牌取订单总运费
  def total_ship_fee(ids)
    @libs = LineItem.where(:id => ids, :state => 1).order("created_at desc").group(:brand_id)
    ship_fee = 0
    unless @libs.blank?
      @libs.each do |li|
        ship_fee += li.sku.get_freight
      end
    end
    ship_fee
  end

  def link_ty_mobile
    #self.mobile = self_user.mobile if self_user
  end

  def generate_order_number
    return unless new_record?
    random = "SJB#{Array.new(9){rand(9)}.join}"
    # record = self.class.where(number: random).first
    self.number = random if self.number.blank?
    self.payment.update_attribute(:out_trade_no, random)
    self.number
  end

  def set_state
    self.state = STATU[:waiting]
  end

  def set_price
    # logger.info self.line_items.inspect
    # logger.info "--------------"
    #
    # self.item_total = self.line_items.where(:state => 1).to_a.sum {|item| item.price.to_f*item.quantity }
    #
    # logger.info "=============="
    #
    # self.shipment_total = total_ship_fee(self.line_items.collect { |li| li.id })
    # self.total = self.item_total.to_f + self.shipment_total.to_f
    # self.payment_total = self.total.to_f
  end

  def check_state
    return if intermediate.nil?
    if intermediate == STATUS[:delivered] && state != STATUS[:confirmed]
      errors.add(:state, "notdelivered")
    end
    if intermediate == STATUS[:confirmed] && state != STATUS[:pending]
      errors.add(:state, "notconfirmed")
    end
    if intermediate == STATUS[:pending] && state != STATUS[:waiting]
      errors.add(:state, "nopending")
    end
    # if intermediate == STATUS[:canceled] && state != STATUS[:waiting]
    #   errors.add(:state, "notcancaled")
    # end
    if intermediate == STATUS[:canceled] && state != STATUS[:canceled]
      # errors.add(:state, "notcancaled")
    end
    if intermediate == STATUS[:waiting]
      errors.add(:state, "notwaiting")
    end
    if intermediate == STATUS[:expired] && state != STATUS[:waiting]
      errors.add(:state, "notexpired")
    end
    if intermediate == STATUS[:completed] && state != STATUS[:delivered]
      errors.add(:state, "ontcompleted")
    end
    if intermediate == STATUS[:removed] && state.in?([11, 22, 33, 44])
      errors.add(:state, "notremoved")
    end
    self.state = intermediate
  end


end
