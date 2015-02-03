require 'rest_client'
require 'json'
require 'qiniu'

def copy_qiniu_file(thing_id)
  keys = ["uploads/cgi/img-thing/size/s/tid/#{thing_id}.jpg", "uploads/cgi/img-thing/size/orig/tid/#{thing_id}.jpg",  "uploads/cgi/img-thing/mask/1/size/orig/tid/#{thing_id}.png"]
  put_policy = Qiniu::Auth::PutPolicy.new(
    'dpms',     # 存储空间
  )

  keys.each do |key|
    p key
    domain = 'http://qingchao1.qiniudn.com/'
    local_file = '/data/' + key
    p local_file

    code, result, response_headers = Qiniu::Storage.delete(
        'dpms',     # 存储空间
        key         # 资源名
    ) 

    next if File.exist?(local_file) and File.size(local_file)>512
    `wget #{domain+key} -O #{local_file}`
    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
      put_policy,     # 上传策略
      local_file,     # 本地文件名
      key,            # 最终资源名，可省略，缺省为上传策略 scope 字段中指定的Key值
    ) 
    p code,result
  end
end


namespace :matter do
  task :import_img, [:thing_id] => :environment do |t, args|
    thing_id = args[:thing_id]
    copy_qiniu_file(thing_id)
  end


  task :sucai_from_sjb => :environment do
    scs =  Category.where("id > 10 and parent_id = 1140").where(:is_active => true).order("weight desc")
    scs.each do |c|
      (1..50).each do |p|
        page = p.to_s
        cid = c.id.to_s
        url = "http://www.shangjieba.com:8080/cgi/search.editor_things.json?.in=json&.out=json&request=%7B%22length%22%3A50%2C%22category_id%22%3A%22#{cid}%22%2C%22page%22%3A#{page}%7D"
        p page, cid, url
        begin
          res = RestClient.get url
          json = JSON.parse(res)
          if json['result']['items'].length > 0 
            json['result']['items'].each do |i|
              copy_qiniu_file(i['thing_id'])
              next if Matter.find_by_image_name(i['thing_id'])
              hash = {}
              hash['image_name'] = i['thing_id']
              hash['width'] = i['w']
              hash['height'] = i['h']
              hash['category_id'] = i['category_id']
              m = Matter.new(hash)
              m.save
              p m
            end
          end
        rescue => e
          p e.to_s
          next
        end
      end
    end
  end

end
