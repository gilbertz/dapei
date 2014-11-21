# -*- encoding : utf-8 -*-
class NotifyPayController < ApplicationController

  def alipay


    new_logger = Logger.new('log/alipay_notify_pay.log')
    new_logger.info("----- Alipay ----- #{Time.now} -----")
    new_logger.info(request.url)
    new_logger.info(params.to_s)


    notify_params = params.except(*request.path_parameters.keys) # 先校验消息的真实性
    logger.info "####################################################33"
    logger.info notify_params
    logger.info "print before verify"

    unless Alipay::Sign.verify?(notify_params) && Alipay::Notify.verify?(notify_params)
      error_new_logger = Logger.new('log/alipay_error.log')
      error_new_logger.info("============================")
      error_new_logger.info("------ #{request.remote_ip} ------")
      error_new_logger.info(request.url)
      error_new_logger.info(params.to_s)
      error_new_logger.info("#{Time.now.to_s}")
      error_new_logger.info("============================")
    end

    @payment = Payment.where(out_trade_no: params[:out_trade_no]).last

    if @payment.blank?
      return render(text: 'success')
    end

    logger.info "finded payment object at database"
    logger.info params[:trade_status]
    num = case params[:trade_status]
            when 'WAIT_BUYER_PAY'; 1 # 交易开启
            when 'WAIT_SELLER_SEND_GOODS'; 2# 买家完成支付
            when 'TRADE_FINISHED'; 3 # 交易完成
            when 'TRADE_CLOSED'; 4 # 交易被关闭
          end
    if @payment.update_attributes(:state => num, :trade_no => params[:trade_no], :amount => params[:total_fee])
      logger.info "alipay return sucess message"
      return render(text: 'success')
    end
    # 成功接收消息后，需要返回纯文本的 'success',否则支付宝会定时重发消息，最多重试7次。
    logger.info "alipay return error message"
    render :text => "error"
  end

  def wxpay

    pay_new_logger = Logger.new('log/wx_notify_pay.log')
    pay_new_logger.info("----- Wxpay ----- #{Time.now} -----")
    pay_new_logger.info(request.url)
    pay_new_logger.info(params.to_s)

    notify_params = params.except(*request.path_parameters.keys)

    puts notify_params.inspect

    new_hash = {}
    notify_params.each do |key, value|
      new_hash[(key.to_s rescue key) || key] = value
    end
    p = notify_params
    sign = p.delete('sign')

    unless wx_v_sign(p, sign)
      new_logger = Logger.new('log/weixin_error.log')
      new_logger.info("============================")
      new_logger.info("------ #{request.remote_ip} ------")
      new_logger.info(request.url)
      new_logger.info(params.to_s)
      new_logger.info("#{Time.now.to_s}")
      new_logger.info("============================")
    end

    logger.info "print weixin verify"
    @payment = Payment.where(out_trade_no: params[:out_trade_no]).last
    logger.info "finded payment object at database"
    logger.info params[:pay_info]
    #num = case params[:trade_status]
    #        when 'WAIT_BUYER_PAY'; 1 # 交易开启
    #        when 'WAIT_SELLER_SEND_GOODS'; 2# 买家完成支付
    #        when 'TRADE_FINISHED'; 3 # 交易完成
    #        when 'TRADE_CLOSED'; 4 # 交易被关闭
    #      end

    if params[:trade_state].to_s == "0"
      num = 3
    else
      num = 1
    end

    total_fee = params[:total_fee].to_f / 100.0

    #订单号
    @payment.update_attributes(:trade_no => params[:transaction_id], :amount => total_fee)

    if @payment.update_attribute(:state, num)
      logger.info "weixin return sucess message"
      return render(text: 'success')
    end
    # 成功接收消息后，需要返回纯文本的 'success',否则支付宝会定时重发消息，最多重试7次。
    logger.info "weixin return error message"

    return render(text: 'error')
  end


  #微信签名验证
  def wx_v_sign(params, sign)
    query = params.sort.map do |key, value|
      "#{key}=#{value}"
    end.join('&')

    query << "&key=7ab40db491b0d7af765bca811cbf182e"

    my_sign = Digest::MD5.hexdigest(query).upcase

    puts my_sign
    puts sign

    my_sign == sign
  end

end
