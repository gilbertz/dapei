class SpiderPages < ActiveRecord::Base
  attr_accessible :brand_id, :spider_id, :category_id, :link, :name, :parent_id, :user_id
  belongs_to :spider

  def get_parent_name
    if self.parent_id
      pc = Category.find_by_id self.parent_id
      pc.name if pc
    else
      '无'
    end
  end

  def get_category(user_id)
    c = Category.find_by_name_and_user_id(self.name, user_id)
    unless c
      c = Category.new
      c.user_id = user_id
      c.parent_id = self.parent_id
      c.name = self.name
      c.save
    end
    c 
  end


end
