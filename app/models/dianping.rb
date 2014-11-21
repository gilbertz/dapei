# -*- encoding : utf-8 -*-
class Dianping

  def initialize
    @dianping_api = "http://api.dianping.com/v1/"
    @key = Rails.configuration.dianping_key
    @secret = Rails.configuration.dianping_secret
  end

  def get_reviews(dp_id)
     url = "#{@dianping_api}/review/get_recent_reviews"

     sign_string = "#{@key}business_id#{dp_id}formatjson#{@secret}"
     @sign = Digest::SHA1.hexdigest(sign_string).upcase 
     res = RestClient.get url, {:params => {:appkey => @key, :sign => @sign, :business_id => dp_id, :format=>"json"  }  }
     return JSON.parse(res)  
  end
end
