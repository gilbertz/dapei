# -*- encoding : utf-8 -*-
# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{203.195.196.54 203.195.191.203}
role :web, %w{203.195.196.54 203.195.191.203}
role :db,  %w{203.195.196.54 203.195.191.203}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
  server '203.195.191.203',
   user: 'ubuntu',
   roles: %w{web app},
   ssh_options: {
     user: 'ubuntu', # overrides user setting above
     keys: %w(/home/ubuntu/.ssh/id_rsa),
     forward_agent: false,
     auth_methods: %w(publickey password),
     password: "shangjieba8"
   }
   
   server '203.195.196.54',
   user: 'ubuntu',
   roles: %w{web app},
   ssh_options: {
     user: 'ubuntu', # overrides user setting above
     keys: %w(/home/ubuntu/.ssh/id_rsa),
     forward_agent: false,
     auth_methods: %w(publickey password),
     password: "HGktK9GrgNv"
   }
