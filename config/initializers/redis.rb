# -*- encoding : utf-8 -*-
require 'redis'


$redis =  Redis.new(:host => REDIS_HOST, :port => 6379)
$redis_crawler =  Redis.new(:host => REDIS_CRAWLER_HOST, :port => 6379)

