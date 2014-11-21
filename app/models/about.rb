# -*- encoding : utf-8 -*-
class About
  attr_accessor :name
  attr_accessor :url
  attr_accessor :i
  attr_accessor :childs
  attr_accessor :action
  # initialize
  class << self
  	def all
  	  # a  = []
  	  # b1 = new
  	  as = [{name:"新手上路",childs:[["购物流程","/about/info/trade","trade"],["会员介绍","/about/info/member_introduce","member_introduce"],["找回密码","/about/info/get_password","get_password"],["帮助中心","/about/info/help","help"]]},
  			{name:"关于我们",childs:[["上街吧介绍","/about/info/about_me","about_me"],["媒体报道","/about/info/report","report"],["招聘信息","/about/info/recruitment","recruitment"],["联系我们","/about/info/contact","contact"]]},
  			{name:"商务合作",childs:[["品牌入驻","/about/info/brand_enter","brand_enter"],["媒体合作","/about/info/collaborate","collaborate"],["广告投放","/about/info/advertisement","advertisement"],["商家中心","/about/info/merchant","merchant"]]},
  			{name:"网站导航",childs:[["品牌大全","/about/info/brand_all","brand_all"],["覆盖城市","/about/info/cover","cover"],["流行风格","/about/info/fashion","fashion"],["网站地图","/about/info/website_map","website_map"]]}]
  	  # b1.name = "新手上路"
  	  # b1.url = ""
  	  i = 0
  	  as.collect{|a|
  	  	b = new
  	  	b.i = i
  	  	b.name = a[:name]
  	  	b.childs=[]
  	  	a[:childs].each{|a1|
  	  	  a2 = new
  	  	  a2.name = a1[0]
  	  	  a2.url = a1[1]
          a2.action = a1[-1]
  	  	  # a2.url += "?i=#{i}" if a2.url != '#'
  	  	  a2.i   = i
  	  	  b.childs << a2
  	  	}
  	  	i += 1
		b  	  	
  	  }
  	end
  end
end
