require 'chinese_pinyin'

head = <<-EOF 
<?xml version="1.0" encoding="utf-8"?>
<sphinx:docset>
<sphinx:schema>
  <sphinx:field name="name"/>
  <sphinx:field name="address"/>
  <sphinx:field name="address_pinyin"/>
  <sphinx:attr name="name" type="string" default=""/> 
  <sphinx:attr name="address" type="string"  default=""/>
  <sphinx:attr name="id" type="int" bits="16" default="1"/>
  <sphinx:attr name="docid" type="int" bits="16" default="1"/>
</sphinx:schema>
EOF

head1 = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<sphinx:docset>
<sphinx:schema>
  <sphinx:field name="keyword"/>
  <sphinx:field name="pinyin"/>
  <sphinx:attr name="keyword" type="string" default=""/> 
  <sphinx:attr name="weight" type="int" bits="16" default="1"/>
  <sphinx:attr name="docid" type="int" bits="16" default="1"/>
</sphinx:schema>
EOF


tail = <<-EOF
</sphinx:docset>
EOF

escape_dict = {"<"=>"&lt;", ">"=>"&gt;", "&"=>"&amp;"}
def escape(input)
   input = input.gsub("<", "&lt;")
   input = input.gsub(">", "&gt;")
   input = input.gsub("&", "&amp;")
end


num = 0
namespace :sphinx do
  
  task :search_suggest => :environment do
    xml_file  = File.new(Rails.root+"./db/query.xml", 'w')
    num += 1
    name_set = Set.new
    xml_file.puts head1
    shops = Shop.all
    shops.each do |shop|
      qs = []
      if shop.street and shop.street != ""
       qs << shop.street
      end
      if shop.brand
        if shop.brand.e_name and shop.brand.e_name != ""
          qs << shop.brand.e_name
        end
        if shop.brand.c_name and shop.brand.c_name != ""
          qs << shop.brand.c_name
        end
      end      

      qs.each do |q|
        if not name_set.include?(q)
          num += 1
          xml_file.puts "<sphinx:document id=\"#{num}\">\n"
          xml_file.puts "   <keyword>#{escape(q)}</keyword>\n"
          xml_file.puts "   <pinyin>#{Pinyin.t(escape(q), '')}</pinyin>\n"
          xml_file.puts "   <weight>1</weight>\n"
          xml_file.puts "   <type>1</type>\n"
          xml_file.puts "   <docid>#{shop.url}</docid>\n"
          xml_file.puts "</sphinx:document>\n"

          name_set << q
        end
      end
    end
    xml_file.puts tail
  end
 

  task :index => :environment do
    xml_file  = File.new(Rails.root+"./db/address.xml", 'w')
    shops = Shop.all
    xml_file.puts head
    shops.each do |shop|
      num += 1    
      xml_file.puts "<sphinx:document id=\"#{num}\">\n"
      if shop.address
        xml_file.puts "   <a>#{escape(shop.address)}</address>\n"
        xml_file.puts "   <address_pinyin>#{Pinyin.t(escape(shop.address), '')}</address_pinyin>\n"
      end
      xml_file.puts "   <type>1</type>\n"
      xml_file.puts "   <docid>#{shop.id}</docid>\n"
      xml_file.puts "</sphinx:document>\n"     
    end
    xml_file.puts tail
  end
end
