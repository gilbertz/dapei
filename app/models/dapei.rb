# -*- encoding : utf-8 -*-
class Dapei < Item
  has_many :items
  
  #has_many :rel_items
  # has_one :dapei_info

  belongs_to :user, :counter_cache => :dapeis_count
  has_many :flash_buy_coin_logs, :as => :relatable

  scope :showing, lambda {
    joins("INNER JOIN dapei_infos ON dapei_infos.dapei_id = items.id").where("items.category_id = 1001 and items.level >= 5").where("dapei_infos.start_date <= DATE('#{Date.today}') and dapei_infos.end_date >= DATE('#{Date.today}')").order("items.created_at desc").limit(10)
  }

  def get_items(page=1, limit=12)
    if self.dapei_info
      self.dapei_info.get_dapei_items(page, limit)
    else
      []
    end
  end


  def get_img_path
    dir = ""
    dir = self.dapei_info.dir.to_s + "/" unless self.dapei_info.dir.blank?
    "/uploads/cgi/img-set/cid/#{dir}#{self.id}/id/#{self.dapei_info.spec_uuid}/size/"
  end


  def to_wenwen
    new_str = Time.now.to_i.to_s + ((100..999).to_a.shuffle[0].to_s)
    local_path = Photo::Sjb_root + self.get_img_path
    local_file_name = "y.jpg"

    m = Matter.new
    m.source_type = 4
    m.is_cut = 0
    m.category_id = 101
    m.local_photo_path = local_path
    m.local_photo_name = local_file_name
    m.image_name = new_str
    m.save
    m.dump

    dr = AskForDapei.create(:user_id => self.user_id, :matter_id => m.id, :dapei_id => self.id, :title => "【荐】大家帮看看我的搭配怎么样?")
    dr
  end


  def get_skus
    if self.dapei_info
      self.dapei_info.get_skus
    else
      []
    end
  end

  def find_brands
    brands = Array.new 
    self.get_matters.each do ||
      brands << m.brand.display_name
    end
    self.btag_list = brands
    if self.dapei_info
      brands << self.dapei_info.tags
    end
    self.tag_list = brands
    self.save
    if self.dapei_info
      self.ctag_list = self.dapei_info.tags
      self.ctag_list.each do |ctag|
        self.user.set_ctag(ctag)
      end
    end
    self.index_info = self.tag_list.join(",")
    self.save
  end


  def get_items_count
    if self.category_id == 1001 and self.dapei_info
      self.dapei_info.dapei_item_infos.length
    else
      "0"
    end
  end

  def get_domain
    AppConfig[:remote_image_domain]
  end

  def get_dpimg_urls(small=false)
    if self.category_id == 1000
      collection = Collection.find_by_id(self.id)
      return collection.get_dpimg_urls
    end
    imgs = []
    if self.category_id == 1001
      temp = {}
      if self.dapei_info
        unless small
          temp[:img_url] = get_domain + self.get_img_path + "y.jpg"
        
          tags = []
          self.dapei_info.get_tag_infos.each do |tag_info|
            tags << {:type => tag_info.tag_type, :point_x => tag_info.point_x,
                   :point_y => tag_info.point_y, :direction => tag_info.direction ? 1 : 0, :name => tag_info.name }
          end
          temp[:tags] = tags
        else
          temp[:img_url] = get_domain + self.get_img_path + "m.jpg"
        end

      else
        temp[:img_url] =  AppConfig[:remote_image_domain] + "/assets/img.jpg"
      end
      unless small
        temp[:width] = 600
        temp[:height] = 600
      else
        temp[:width] = 150
        temp[:height] = 150
      end
      imgs << temp
    end

    imgs
  end


  def make_share_img
    bg_dir = "#{Photo::Sjb_root}/app/assets/images/newweb/bg600x673.jpg"
    image = MiniMagick::Image.open(bg_dir)
    return  unless self.dapei_info
    dp_img = Photo::Sjb_root + "/public" + self.get_img_path + "y.jpg"
    dp_share_img = Photo::Sjb_root + "/public" + self.get_img_path + "y_s.jpg"
    return  if FileTest::exist? dp_share_img

    unless FileTest::exist? dp_img
      url = get_domain + self.get_img_path + "y.jpg"
      `wget #{url} -O dp_img`
    end

    return unless FileTest::exist? dp_img

    image.draw "image over 0, 0, 600, 600 '#{dp_img}'"
    water_img = Photo::Sjb_root + "/public/uploads/shuiyin.png"

    image.draw "image over 0, 600, 600, 73 '#{water_img}'"
    image.write dp_share_img
  end

  def make_share_img1
    bg_dir = "#{Photo::Sjb_root}/app/assets/images/newweb/bg600x673.jpg"
    image = MiniMagick::Image.open(bg_dir)
    puts "aaaaaa"
    return "0" unless self.dapei_info
    dp_img = Photo::Sjb_root + "/public" + self.get_img_path + "y.jpg"
    dp_share_img = Photo::Sjb_root + "/public" + self.get_img_path + "y_s.jpg"
    puts dp_img
    puts dp_share_img
    puts "bbbbbbbb"
    return "1" if FileTest::exist? dp_share_img

    unless FileTest::exist? dp_img
      url = get_domain + self.get_img_path + "y.jpg"
      `wget #{url} -O dp_img`
      puts "ccccccc"
    end

    return "2" unless FileTest::exist? dp_img

    image.draw "image over 0, 0, 600, 600 '#{dp_img}'"
    water_img = Photo::Sjb_root + "/public/uploads/shuiyin.png"

    image.draw "image over 0, 600, 600, 73 '#{water_img}'"
    image.write dp_share_img
  end


  def img_url(size='y')
    if self.category_id == 1000
      return "" unless self.transform
      self.transform.img_url(size)
    else
      size = 'y' if size != 'm' and size != 'y_s'
      if self.id < 5496600
        size = 'y' if size == 'y_s'
      end

      unless (dpi = self.dapei_info).blank?
        self.get_domain + self.get_img_path + "#{size}.jpg"
      else
        ""
      end
    end
  end

  def dapei_img_url
    if self.category_id == 1000
      self.transform.dapei_img_url
    else
      if self.dapei_info
        self.get_domain + self.get_img_path + "m.jpg"
      end
    end
  end


  def user_name
    if self.get_user
      self.get_user.name.to_s
    else
      ""
    end
  end

  def user_url
    if self.get_user
      self.get_user.url
    else
      ""
    end
  end

  def user_img_small
    if self.get_user
      self.get_user.display_img_small
    else
      ""
    end
  end


  def self.dup(dapeis)
    uids = []
    dps = []
    dapeis.each do |d|

      unless d.blank?
        unless uids.include?(d.user_id)
          dps << d
        end
        uids << d.user_id
      end

    end
    dps
  end

  def get_dapeis(limit, page)
    Dapei.v_dapeis_by(self.get_user).page(page).per(limit)
  end


  def self.by_url(url)
    dp = Dapei.find_by_url(url)
    return dp if dp
    cells = url.split('@')
    if cells.length == 2
      dp = Dapei.find_by_url(cells[0])
      u = User.find_by_url(cells[1])
      dp.user_id = u.id if dp and u
      return dp if dp
    end
  end


  def notify_pv
    if self.get_user
      self.get_user.dapei_pv_notify(self.url)
    end
  end


  def get_dapei_tag
    if self.dapei_info and self.dapei_info.dapei_tags_id and self.dapei_info.dapei_tags_id != 0
      DapeiTag.find self.dapei_info.dapei_tags_id
    end
  end

  # 得到今天中午12:00,到次日的12:00的喜欢最多的搭配
  def self.get_24hour_star
    # start_at = Time.local(2014,8,1,12)
    # end_at = Time.local(2014,8,2,12)
    current_time = Time.now - 1.days
    next_time = Time.now
    start_at = Time.local(current_time.year, current_time.month, current_time.day, 12)
    end_at = Time.local(next_time.year, next_time.month, next_time.day, 12)
    dp = Like.where(:created_at => start_at..end_at, :target_type => 'Item').group('target_id').select('count(target_id) like_num, target_id dapei_id').order("like_num desc").limit(1).first
    if dp
      dapei = Dapei.find(dp.dapei_id)
      FlashBuy::Api.add_coin(dapei, 'star_dapei')
    end
  end

  def self.cron_review(key, num)
    keys = $redis.lrange(key, 0, -1)
    remain = $redis.lrange(key, 0, -1).length

    em = {23 => 0, 7 => 1, 8 => 2}
    t = Time.now
    if t.hour > 23 or t.hour < 7
      num = 0
    else
      unless t.strftime("%w").to_i == 0
        len = $redis.llen(key)
        if [23, 7, 8].include?(t.hour)
          num = len/(3-em[t.hour])
        end
      end
      unless [23, 7, 8].include?(t.hour)
        if remain < 10
          num = 1
        end
      end
    end

    p keys
    ids = []
    keys.each do |k|
      dp = Dapei.find_by_url(k)
      ids << dp.id if dp
    end
    ids = ids.sort.uniq
    p ids[0, num]
    ids[0, num].each do |id|
      p id
      dp = Dapei.find_by_id(id)
      p dp.url
      pre_level = 0
      pre_level = dp.level.to_i if dp
      if dp
        p 'review dp.url=', dp.url
        level = $redis.get('level_' + dp.url)
        dp.level = level
        dp.save
        if pre_level <=0 and dp.level.to_i >= 2
          PushNotification.push_review_dapei(dp.get_user.id, dp.url)
          dp.rand_like
        end
      end
      $redis.lrem(key, -1, dp.url)
    end
  end

end
