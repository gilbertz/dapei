# -*- encoding : utf-8 -*-
#if Rails.env.eql? "development"
ChinaSMS.use :smsbao, username: 'shangjieba', password: 'shangjieba123'
#else
  #nil
#end

# 中文名
$app_name = "美格时尚"
