namespace :crawler do
  redis =  Redis.new(:host => '114.80.100.12', :port => 6379)
  task :brand_template => :environment do
    s  = "/var/www/shangjieba_dat/weibo/weibo_brand.txt"
    File.new(s).each do |line|
      items  = line.strip().split(/\t+/)
      doc = {}
      doc[:t] = "Item"
      doc[:template] = "weibo"
      if items.length >= 3
        doc[:source] = items[0]
        doc[:brand_name] = items[1]
        doc[:pattern] = items[2]
        print doc
        ct =  CrawlerTemplate.find_by_brand_name_and_template(doc[:brand_name], doc[:template])
        if not ct 
          CrawlerTemplate.create(doc)
        else
          ct.update_attributes(doc)
        end
      end
    end 
  end

  task :sync_weibo_template => :environment do
    weibo_crawler_templates = CrawlerTemplate.where{template=="weibo"}.order{t}
    weibo_crawler_templates.each do |weibo_template|
       t_val = weibo_template.t
       weibo_template.update_attribute(:t, "Item") if t_val.nil? || t_val.strip.empty?
       line = "#{weibo_template.source}\t#{weibo_template.brand_name}\t#{weibo_template.pattern}\t#{weibo_template.brand_id}\t#{weibo_template.t}\t#{weibo_template.template}\t#{weibo_template.mall_id}"
       puts line
       weibo_brand_new_queue = redis.lrange("weibo_brand_new",0,-1)
       redis.rpush("weibo_brand_new", line) unless weibo_brand_new_queue.include?(line)
    end
  end

  task :sync_homepage_template => :environment do
    s  = "/var/www/shangjieba_dat/casperjs/homepage_brand_new.txt"
    f = File.new(s, 'w')
    cts = Spider.order('created_at desc')
    cts.each do |ct|
       if true
         line = "#{ct.brand_id}\t#{ct.brand.name}\n"
         print line
         f.write(line)
       end
    end
    f.close()
    upload = "/var/www/shangjieba/upload.exp"
    target = "/home/wanhuir/wps/iSpider/casperjs/casperjs_brand.txt"
    `#{upload} wanhuir.com wanhuir wan123 36000 #{s} #{target} 300`
  end

end
