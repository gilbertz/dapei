# -*- encoding : utf-8 -*-
require 'baidu_push'

api_key = "EqH2rNPlffpk7kTyfjeDVAc1"
secret_key = "B5Vwfsdim9lvhKkrDeMl468O0KHGFLjl" 
$baidu_client = BaiduPush::Client.new(api_key, secret_key)
