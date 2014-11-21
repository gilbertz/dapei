# -*- encoding : utf-8 -*-

class Category < ActiveRecord::Base
  validates :name,  :presence => true,  :length => { :maximum => 255 }
  has_many :children, :class_name => "Category",:foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Category"
  has_many :items
  has_many :skus
  attr_accessible :abb, :name, :id, :parent_id, :weight, :is_active, :synonym, :thing_img_id, :image_thing, :desc, :app_icon_image, :is_active_for_app, :min_price, :max_price
  has_many :synonyms

  attr_accessor :tags

  scope :sub, lambda { |cid|
    where( :parent_id => cid  ).where(:is_active => true).order("weight desc")
  }

  scope :active, 
    where(:is_active => true).order("weight desc")
  

  acts_as_api
  api_accessible :public,  :cache => 300.minutes do |t|
    #t.add :id
    t.add lambda{|category| category.id.to_s}, :as => :id
    t.add :abb
    t.add :name
    t.add :image_thing
    t.add :img_url
    t.add :weight
    t.add :is_active
    #t.add lambda{|category| Category.sub(category.id) }, :as => :sub_categories
  end

  
  acts_as_api
  api_accessible :priv,  :cache => 300.minutes do |t|
    #t.add :id
    t.add lambda{|category| category.id.to_s}, :as => :id
    t.add :abb
    t.add :name
    t.add :image_thing
    t.add :img_url
    t.add :weight
    t.add :is_active 
    t.add lambda{|category| Category.sub(category.id) }, :as => :sub_categories
  end


  acts_as_api
  api_accessible :dp,  :cache => 300.minutes do |t|
    #t.add :id
    t.add lambda{|category| category.id.to_s}, :as => :id
    t.add :abb
    t.add :get_dp_name, :as => :name
    t.add :image_thing
    t.add :get_icon_image, :as => :img_url
    t.add :weight
    t.add :is_active
    t.add :desc
    t.add :tags 
    t.add lambda{|category| Category.dp_sub(category.id) }, :as => :sub_categories
  end


  def self.dp_sub(cid)
    results = []
    Category.sub(cid).each do |cat|
      #cat.tags = DapeiInfo.tag_counts_on(:tags) 
      cat.tags = cat.get_tags
      if cat.is_active_for_app == 1 and cat.tags.length > 0
        results << cat
      end
    end
    results
  end


  def star_name
    if self.parent_id  == 1
      self.name
    else
      "--" + self.name
    end
  end


  def get_dp_name
    if self.parent_id == 1
      self.name.to_s + '怎么搭'
    else
      self.name.to_s
    end
  end


  def get_tags
    tags = Rails.cache.fetch "tags_#{self.id}", :expires_in => 120.minutes do
      s = Searcher.new("", "matter", nil, nil, 100, 1)
      s.set_sub_category_id( self.id )
      s.set_level(9)
      matters = s.search()
    
      tag_dict = {}
      #tag_lists = matters.map{|m| m.sku.tags unless m.blank? or m.sku.blank? }
      tag_sku_dict = {}
      tag_lists = []      

      matters.each do |m|
        next if not m or not m.sku
        tag_lists << m.sku.tags
        m.sku.tags.each do |t|
          unless tag_sku_dict[t.id]
            tag_sku_dict[t.id] = m.sku.id if m.sku
          end
        end 
      end

      #p tag_sku_dict, tag_lists

      unless tag_lists.blank?
        tag_lists.each do |tl|
          unless tl.blank?
            tl.each do |t|
              if tag_dict[t.id]
                tag_dict[t.id] += 1
              else
                tag_dict[t.id] = 1
              end
            end
          end
        end
      end

      tag_dict = tag_dict.sort{|a,b| b[1]<=>a[1] }
      
      tag_list = [] 
      show_num = 0

      sku_list = []
      tag_dict.each do |k, v|
        sku_id = tag_sku_dict[k]
        next if sku_list.include?( sku_id  )
        sku_list << sku_id

        tag = Tag.find(k)
        next if tag.is_show == 0
        desc_tag = DescTag.find_by_category_id_and_tag_id(self.id, k)
        tag_desc = tag.desc.to_s if tag
        next if desc_tag and desc_tag.is_show == 0
        tag_desc = desc_tag.desc if desc_tag 
        tag_list << {:count => v, :name => tag.name, :id => tag.id, :desc => tag_desc}
        show_num += 1
        break if show_num > 6
      end
      tag_list
    end
    tags
  end
  
  def get_icon_image
    unless self.app_icon_image.blank?
      self.app_icon_image
    else
      self.img_url
    end
  end


  def img_url
      unless self.image_thing.blank?
        AppConfig[:remote_image_domain] + "/uploads//cgi/img-thing/size/s/tid/#{self.image_thing}.jpg"
      else
        AppConfig[:remote_image_domain] + "/uploads//cgi/img-thing/size/s/tid/2013092106.jpg"
      end
  end

  def thing_img_url
    unless self.thing_img_id.blank?
      AppConfig[:remote_image_domain] + "/uploads//cgi/img-thing/size/s/tid/#{self.thing_img_id}.jpg"
    else
      AppConfig[:remote_image_domain] + "/uploads//cgi/img-thing/size/s/tid/2013092106.jpg"
    end
  end

  def self.is_sub(cid)
    cat = Category.find_by_id(cid)
    if cat
      if cat.parent_id == 1140 and cat.is_active
        return false
      end
      if cat.parent_id.to_i < 100 and  cat.parent_id.to_i > 3
        parent = Category.find(cat.parent_id)
        return true if parent and parent.thing_img_id
      end
    end
    return false
  end

  #获取所有一级分类
  def self.get_first_categories
    Category.where(:parent_id => 1).where("id != 1").all
  end

  #获取所有active一级分类
  def self.get_first_active_categories
    Category.where(:parent_id => 1).where("id != 1").all
  end

  #获取所有二级分类
  def self.get_all_sub_categories(pid=0)
    if pid == 0
      cids = Category.where(:parent_id => 1).where("id != 1").map(&:id)
      Category.where(:parent_id => cids).all
    else
      Category.where(:parent_id => pid).where("id != 1").all
    end
  end

  #获取所有active二级分类
  def self.get_all_active_sub_categories(pid=0)
    if pid == 0
      cids = Category.where(:parent_id => 1).where("id != 1").map(&:id)
      Category.where(:parent_id => cids).all
    else
      Category.where(:parent_id => pid).where("id != 1").all
    end
  end

  def self.get_active_categories
    categories = []
    main_categories = Category.where(:id => [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14])
    main_categories.each do |c|
      categories << c
      categories += Category.sub(c.id)
    end
    categories
  end
 
end
