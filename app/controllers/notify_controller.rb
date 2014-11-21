# -*- encoding : utf-8 -*-
class NotifyController < ApplicationController

  def alipay
    notify_params = params.except(*request.path_parameters.keys) # 先校验消息的真实性
    logger.info "####################################################33"
    logger.info notify_params
    logger.info "print before verify"
    unless Alipay::Sign.verify?(notify_params) #&& Alipay::Notify.verify?(notify_params)

      new_logger = Logger.new('log/alipay_error.log')
      new_logger.info("============================")
      new_logger.info("------ #{request.remote_ip} ------")
      new_logger.info(request.url)
      new_logger.info(params.to_s)
      new_logger.info("#{Time.now.to_s}")
      new_logger.info("============================")

    end

      logger.info "print alipay verify"
      @payment = Payment.find_by!(out_trade_no: params[:out_trade_no])
      logger.info "finded payment object at database"
      logger.info params[:trade_status]
      num = case params[:trade_status]
            when 'WAIT_BUYER_PAY'; 1 # 交易开启
            when 'WAIT_SELLER_SEND_GOODS'; 2# 买家完成支付
            when 'TRADE_FINISHED'; 3 # 交易完成
            when 'TRADE_CLOSED'; 4 # 交易被关闭
            end
      if @payment.update_attribute(:state, num)
        logger.info "alipay return sucess message"
        return render(text: 'success')
      end
      # 成功接收消息后，需要返回纯文本的 'success',否则支付宝会定时重发消息，最多重试7次。 
      logger.info "alipay return error message"

  end

  def wxpay
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
      render :text => "error"
      return
    end

    logger.info "print weixin verify"
    @payment = Payment.find_by!(out_trade_no: params[:out_trade_no])
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

    @payment.update_attribute(:pay_info, params[:pay_info])

    if @payment.update_attribute(:state, num)
      logger.info "weixin return sucess message"
      return render(text: 'success')
    end
    # 成功接收消息后，需要返回纯文本的 'success',否则支付宝会定时重发消息，最多重试7次。
    logger.info "weixin return error message"

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
