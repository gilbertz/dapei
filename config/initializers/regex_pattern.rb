# -*- encoding : utf-8 -*-
pat_file = Rails.root + 'db/seed/pat.yml'
pat_list = YAML::load( File.open( pat_file ) )
$street_pat = ""
$jinjiao_pat = ""
$dis_pat = ""
pat_list.each_pair do |key,pat|
   $street_pat = pat['street_pat'].force_encoding("ASCII-8BIT")
   $jinjiao_pat = pat['jinjiao_pat'].force_encoding("ASCII-8BIT")
   $dis_pat = pat['dis_pat'].force_encoding("ASCII-8BIT")
end
