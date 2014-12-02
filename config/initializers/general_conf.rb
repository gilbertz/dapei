# -*- encoding : utf-8 -*-
#if Rails.env.eql? "development"
ChinaSMS.use :smsbao, username: 'dapeimishu', password: 'dapei123'
#else
  #nil
#end

# 中文名
$app_name = "搭配秘书"
