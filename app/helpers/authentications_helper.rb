# -*- encoding : utf-8 -*-
module AuthenticationsHelper
  def post_content
    str="：[太开心]亲们，我刚刚加入靠谱、时尚的#上街吧#大家庭，开始与很多美妞们一起上街淘衣啦！这里，有上海每个商场和服装街的最新款美衣，和闺蜜一起挖掘潮店，淘尽新品，发现超值折扣。赶快加入我们吧！[围观]>>> http://www.shangjieba.com  @上街吧 "
    str.html_safe  
  end
end
