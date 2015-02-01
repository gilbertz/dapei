#!/bin/bash

source /usr/local/rvm/scripts/rvm 
cd /data/dapeimishu
RAILS_ENV=production bundle exec rake matter:dispose > /tmp/matter_dispose.log
