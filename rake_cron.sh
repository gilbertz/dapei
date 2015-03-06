#!/bin/bash

source /usr/local/rvm/scripts/rvm 
cd /data/dapeimishu
RAILS_ENV=production bundle exec rake item:update_index_info > /tmp/update_index_info.log
RAILS_ENV=production bundle exec rake dapei:fill_matter > /tmp/fill_matter.log
