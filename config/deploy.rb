require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm' # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

ENV["to"] ||= 'dp'
case ENV["to"]
  when 'dp'
    set :domain, '121.42.47.121'
    set :user, 'root'
    set :password, 'bNg42mjv'
    set :deploy_to, '/data/www/apps/dapeimishu'
    ENV['port'] = '7000'
    ENV['data_path'] = '/data'
end

set :rvm_path, '/usr/local/rvm/bin/rvm'

# set :deploy_to, '/var/www/shangjeiba.com'
# set :repository, 'git@git.wanhuir.com:shangjieba.git'
set :repository, 'git@git.dapeimishu.com:wps/dapeimishu.git'

# set :branch, 'sidekiq'
set :branch, 'master'
set :keep_releases, 5


# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.0.0-p481]'

end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    #invoke :'rails:db_migrate' if ENV['to'] == 'dp'
    #invoke :'rails:assets_precompile'

    # invoke :'deploy:cleanup'

    to :launch do
      invoke :'data_links'
      # invoke :'cp_file'
      # queue "touch #{deploy_to}/tmp/restart.txt"
      # invoke :assets_precompile
      invoke :'passenger'
      #invoke :'whenever'
      invoke :'sidekiq'
      invoke :'deploy:cleanup'
    end
  end
end

# task :assets_precompile => :environment do
#   queue %[cd #{deploy_to}/#{current_path}/public && ln -s #{deploy_to}/#{shared_path}/assets assets]
#   queue %[cd #{deploy_to}/#{current_path} && bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile]
# end

task :passenger => :environment do
  invoke :passenger_stop
  invoke :passenger_start
end

task :passenger_start => :environment do
  queue "cd #{deploy_to}/#{current_path} && passenger start -a 0.0.0.0 -p #{ENV['port']} -d -e production --pid-file #{deploy_to}/#{shared_path}/passenger.#{ENV['port']}.pid"
end

task :passenger_stop => :environment do
  quene "touch #{deploy_to}/#{current_path}/passenger.#{ENV['port']}.pid"
  queue "cd #{deploy_to}/#{current_path} && passenger stop -p #{ENV['port']} --pid-file #{deploy_to}/#{shared_path}/passenger.#{ENV['port']}.pid"
end

#task :whenever => :environment do
#  queue! %[cd #{deploy_to}/#{current_path} && bundle exec whenever --update-crontab sjb]
#end

task :cp_file => :environment do
  # queue! %[cp #{deploy_to}/#{shared_path}/config/database.yml #{deploy_to}/#{current_path}/config/]
end

task :data_links => :environment do
  queue %[cd #{deploy_to}/#{current_path}/public && ln -s #{ENV['data_path']}/uploads/cgi cgi]
  queue %[cd #{deploy_to}/#{current_path}/public && ln -s #{ENV['data_path']}/uploads uploads]
end

task :sidekiq => :environment do
  invoke :sidekiq_stop
  invoke :sidekiq_start
end

task :sidekiq_start => :environment do
  queue %[cd #{deploy_to}/#{current_path} && rm -rf config.ru]
  queue %[cd #{deploy_to}/#{current_path} && cp  #{deploy_to}/#{shared_path}/config.ru config.ru]
  queue %[cd #{deploy_to}/#{current_path} && bundle exec rails s -d -e production -p 3001]
  queue %[cd #{deploy_to}/#{current_path} && bundle exec sidekiq -C config/sidekiq.yml -d -e production]
end

task :sidekiq_stop => :environment do
  queue %[kill `lsof -t -i:3001`]
  queue %[cd #{deploy_to}/#{current_path} && bundle exec sidekiqctl quiet log/pids/sidekiq.pid]
  queue %[cd #{deploy_to}/#{current_path} && bundle exec sidekiqctl stop log/pids/sidekiq.pid]
end


desc "Rollback to previous verison."
task :rollback => :environment do
  queue %[echo "----> Start to rollback"]
  queue %[if [ $(ls #{deploy_to}/releases | wc -l) -gt 1 ]; then echo "---->Relink to previos release" && unlink #{deploy_to}/current && ln -s #{deploy_to}/releases/"$(ls #{deploy_to}/releases | tail -2 | head -1)" #{deploy_to}/current && echo "Remove old releases" && rm -rf #{deploy_to}/releases/"$(ls #{deploy_to}/releases | tail -1)" && echo "$(ls #{deploy_to}/releases | tail -1)" > #{deploy_to}/last_version && echo "Done. Rollback to v$(cat #{deploy_to}/last_version)" ; else echo "No more release to rollback" ; fi]
  invoke :passenger
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

