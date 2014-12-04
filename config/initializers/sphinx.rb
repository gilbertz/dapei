# -*- encoding : utf-8 -*-

require File.dirname(__FILE__)+'/../../lib/sphinx/init.rb'

begin
  $sphinx = Sphinx::Client.new()
  $sphinx.SetServer(SPHINX_HOST, 9314)
rescue=>e
  print e, "sphinx bad init!"
end
