# encoding: utf-8
# 优品闪购api
class FlashBuy::Api

  # 增加币的类型
  # publish_dapei 发布搭配 +10, 回答搭配 answer_dapei +5 ,推精选首页 + 500
  COIN_ADD_TYPE = {"publish_dapei" => 20, "answer_dapei" => 5, "push_homepage" => 500, "star_dapei" => 5000}
  class << self
    def add_coin(obj, type)
      value = COIN_ADD_TYPE[type]
      raise '增加闪币类型错误' if value.blank?
      #  调用flash_buy_api
      case obj
        when Dapei ,DapeiResponse
          user = obj.user
      end
      if user
        if check_get_coin(user, obj, type)
          ActiveRecord::Base.transaction do
            flash_buy_update_coin(user, value)
            case obj
              when DapeiResponse
                obj = obj.request
            end
            FlashBuyCoinLog.create_coin_log(user, obj, type, false, value)
          end
        else
          p '不能得到闪币'
        end
      end
    end

    def remove_coin(type, value)

    end

    #同步这个用户到优品闪购的闪币
    def sync_coin(user)
      ActiveRecord::Base.transaction do
        flash_buy_update_coin(user, user.coin)
        user.update_attribute(:coin, 0)
      end
    end

    # 得到闪币数
    def get_coin(user)
      response = RestClient.get(SG_DOMAIN + "/users/#{user.userinfo.shangou_id}.json?token=#{user.userinfo.shangou_token}")
      res = ActiveSupport::JSON.decode(response)
      res["user"]["coin"]
    end

    # 检查是否能得到币
    def check_get_coin(user, obj, type)
      case type
        when 'publish_dapei' # 发布搭配 每人每天10个有效
          log_count = user.flash_buy_coin_logs.where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day, :coin_type => type).count
          log_count >= 10 ? false : true
        when 'push_homepage', 'star_dapei' # 回答搭配,推荐到首页 只有一个有效获取闪币
          log = user.flash_buy_coin_logs.query_relatable(obj).where(:coin_type => type)
          log.present? ? false : true
        when 'answer_dapei'
          log = user.flash_buy_coin_logs.query_relatable(obj.request).where(:coin_type => type)
          log.present? ? false : true
      end
    end

    private


    def flash_buy_update_coin(user, value)
      p "#{user.name} 得到 闪币 #{value}"
      if user.is_bind_flash_buy?
        RestClient.put("#{SG_DOMAIN}/api/coin/#{user.userinfo_shangou_id}/add/#{value}/#{user.userinfo_shangou_token}",{})
      else
        user.increment!(:coin, value)
      end

      # 清除一下相关缓存
      Rails.cache.delete("u_#{user.id}_money")
    end
  end
end