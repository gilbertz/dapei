# -*- encoding : utf-8 -*-

require File.dirname(__FILE__)+'/../../lib/sphinx/init.rb'

begin
$sphinx = Sphinx::Client.new()
$sphinx.SetServer(SPHINX_HOST, 9314)
#$sphinx.SetMatchMode(Sphinx::SPH_MATCH_FULLSCAN)

$sphinx1 = Sphinx::Client.new()
$sphinx1.SetServer(SPHINX_HOST, 9314)

$sphinx2 = Sphinx::Client.new()
$sphinx2.SetServer(SPHINX_HOST, 9314)

$sphinx_xml = Sphinx::Client.new()
$sphinx_xml.SetServer("114.80.100.12", 9319)


$sphinx_i = Sphinx::Client.new()
$sphinx_i.SetServer(SPHINX_HOST, 9314)

$sphinx_ii = Sphinx::Client.new()
$sphinx_ii.SetServer(SPHINX_HOST, 9314)


#lon = 121.463392
#lat = 31.224541
#lat = (lat / 180.0) * Math::PI
#lon = (lon / 180.0) * Math::PI
#print lat, lon

#$sphinx.SetGeoAnchor('lat_radians', 'long_radians', lat, lon)
#$radius = 1000.0
#$sphinx.SetFilterFloatRange('@geodist', 0.0, $radius)
#$sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXTENDED, '@geodist ASC, @relevance DESC')
#print $sphinx.Query('')
#$sphinx.ResetFilters()

rescue=>e
print e, "sphinx bad init!"
end
