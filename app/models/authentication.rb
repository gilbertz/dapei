# -*- encoding : utf-8 -*-
class Authentication < ActiveRecord::Base
  attr_accessible :user_id, :provider, :uid, :access_token, :expires_at
  belongs_to :user
  validates :provider, :uid, presence: true
  def self.find_from_hash(hash)
    print "(((((((((((((((((((((((((((((((((( in find hash" 
    uid = hash['uid']
    #authen=Authentication.where(:provider => hash['provider'], :uid => uid.to_s).first()
    authen=Authentication.where(:uid => uid.to_s).first()
    user=nil
    if(authen)
      user=User.find_by_id(authen.user_id)
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
      print hash["credentials"]["expires_at"]
      authen.update_attributes({:expires_at=>hash["credentials"]["expires_at"], :access_token=>hash["credentials"]["token"]})
      #post_to_qq(hash["credentials"]["token"],  hash['uid'] )
    end
    user
  end

  def self.find_from_hash_remote(hash)
    uid = hash['uid']
    #authen=Authentication.where(:provider => hash['provider'], :uid => uid.to_s).first()
    authen=nil
    authen=Authentication.where(:uid => uid.to_s).first()
    user=nil
    if(authen)
      #user=User.where(:id=>authen.user_id).first()
      user=User.find_by_id(authen.user_id)
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
      #print hash["credentials"]["expires_at"]
      #authen.update_attributes({:expires_at=>hash["credentials"]["expires_at"], :access_token=>hash["credentials"]["token"]})
    end
    user
  end

  def self.create_from_hash(hash, user)
    print "in ))))))))))))))))))))))))))))))))))))))))) create from hash"
    uid = hash['uid']
    #uid = hash['info']['name'] if uid.blank?
    a = Authentication.new(:user_id=>user.id, :uid => uid.to_s, :provider => hash['provider'], :access_token=>hash["credentials"]["token"], 
      :expires_at=>hash["credentials"]["expires_at"])
    #user.authentications << a
    #print a.to_json
    unless a.save
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    end
    print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    #if hash['provider']=="weibo"
    post_to_weibo(hash["credentials"]["token"], hash["credentials"]["expires_at"])
    #else
      #post_to_qq(hash["credentials"]["token"],  hash['uid'] )
    #end
    user
  end

  def self.create_from_hash_remote(hash, user)
    uid = hash['uid']
    #uid = hash['info']['name'] if uid.blank?
    a = Authentication.new(:user_id=>user.id, :uid => uid.to_s, :provider => hash['provider'])
    #user.authentications << a
    #print a.to_json
    unless a.save
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    end
    user
  end

  def self.post_to_weibo(access_token, expires_at)
    print "@@@@@@@@@@@@@now in the Weibo's post function"
    message="[太开心]亲们，我刚刚加入#上街吧#大家庭，太好看了，太好玩啦！[围观]>>> http://a.app.qq.com/o/simple.jsp?pkgname=com.shangjieba.client.android&g_f=991653  @上街吧 "
    WeiboOAuth2::Config.api_key =1485201157
    WeiboOAuth2::Config.api_secret = "1e080c6a5465838dc5bb54d710d7992a"
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash({:access_token=>access_token, :expires_at=>expires_at})
    statuses = client.statuses
    #pic_dir=Dir.pwd+"/app/assets/images/"+"weibophoto.jpg"
    pic_dir = "http://qingchao1.qiniudn.com/uploads/cgi/img-set/cid/5488962/id/RDRWt6BikGCux63sGhu2/size/y.jpg"
    pic=File.open(pic_dir)
    statuses.upload(message, pic)
    #statuses.update(message)
  end

  def self.post_to_qq(access_token, uid)
    print "@@@@@@@@@@@@@now in QQ's post function"
    message="[太开心]亲们，我刚刚加入#上街吧#大家庭，太好看了，太好玩啦！[围观]>>> http://a.app.qq.com/o/simple.jsp?pkgname=com.shangjieba.client.android&g_f=991653  @上街吧 "
    #pic_dir=Dir.pwd+"/app/assets/images/"+"weibophoto.jpg"
    pic_dir = "http://qingchao1.qiniudn.com/uploads/cgi/img-set/cid/5488962/id/RDRWt6BikGCux63sGhu2/size/y.jpg"
    qq_add_pic_t(message, pic_dir, access_token, uid)
  end

  def self.qq_add_pic_t(content, image, access_token, uid)
    conn = Faraday.new(:url => 'https://graph.qq.com') do |faraday|
      faraday.request :multipart
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    ret=conn.post '/t/add_pic_t', :content => content, :pic => Faraday::UploadIO.new(image, 'image/jpeg'), :access_token => access_token, :openid => uid, :oauth_consumer_key =>100407222
    ret
  end

end
