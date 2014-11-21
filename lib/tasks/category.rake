#encoding: utf-8

namespace :dat do
  task :category => :environment do
    file_to_load  = Rails.root + 'db/seed/categories.yml'
    categories_list   = YAML::load( File.open( file_to_load ) )
    categories_list.each_pair do |key,category|
      begin
        p category
        s = Category.find_by_id(category['id'])
        Category.create(category) unless s
        s.update_attributes(category) if s
      rescue=>e
        next
      end
    end
  end

  #used to sync the backward category dictionary to the forward taxonomy
  task :sync_category => :environment do
    head_file  = Rails.root + 'db/seed/head.txt'
    label_file  = Rails.root + 'db/seed/label.txt'
    cat_hash={}
    load_cat_file(head_file,cat_hash)
    load_cat_file(label_file,cat_hash)
    cat_hash.each do |k,v|
      s=Category.find_by_name(k)
      #if s
        #p k
      #end
      unless s
        cat=Category.new
        cat.name=k
        cat.weight=0
        cat.is_active=false
        parent=Category.find_by_name(v)
        if parent
          cat.parent_id=parent.id
        end
        #p cat
        cat.save
      end
    end
  end

  def load_cat_file(dict_file_name,cat_hash)
    fn = Rails.root + dict_file_name
    cat = ""
    File.new(fn).each do |line|
      line  = line.strip()
      if line[0] == "*"
         cat = line[1, 20]
         #p cat
         next
      end
      if line != ""
         line=line.strip()
         words=line.downcase.split(' ')
         next if words.length!=2
         cat_hash[words[0]] = cat
      end
    end
  end


  task :sku_de_classify => :environment do
    Sku.where( "category_id >= ?", 1000 ).each do |s|
      p s.title, s.brand.name, s.category_id
      s.tags = s.tags.to_s +  Category.find_by_id(s.category_id).name
      p s.tags
      s.category_id = 3
      s.save
    end
  end


  task :shop_classify => :environment do
    Brands.where( "level>=?", 3 ).each do |b|
      brand.shops.each do |s|
        s.category_id = brand.category_id
        s.save 
      end
    end
  end

  task :cat_dict => :environment do
    file_to_load  = Rails.root + 'db/seed/tags.dic'
    file_to_load1  = Rails.root + 'db/seed/brands.dic'
    file_out = File.new(Rails.root + 'db/seed/sjb.dic', "w")
    File.new(file_to_load).each do |line|
      begin
        p line
        line  = line.strip
        ss = line.split(' ')
        p ss
        file_out.write( "#{ss[1].length} #{ss[1].downcase}\n") 
      rescue=>e
        p e.to_s
        next
      end
    end
    File.new(file_to_load1).each do |line|
      begin
        line = line.strip
        ss = line.split(' ')
        file_out.write( "#{ss[1].length} #{ss[1].downcase}\n" )
      rescue=>e
        next
      end
    end
  end


  task :item_classify => :environment do
     require 'rmmseg'
     tag_path =  Rails.root + 'db/seed/sjb.dic'
     p tag_path
     #RMMSeg::Dictionary.load_dictionaries
     File.new(tag_path).each do |line|
       dd = line.split(' ')
       if dd.length >= 2
         RMMSeg::Dictionary.add(dd[1], dd[0].to_i, 1)
       end
     end    

     p "棉服", RMMSeg::Dictionary.has_word?("棉服")

     count = Sku.maximum('id').to_i
     for id in (1..count+1) do
         sku= Sku.find_by_id(count-id+1)
         next if not sku
         next if sku.category_id != 3
         next if sku.category_id > 100
         next if sku.from !~ /homepage/
         title = sku.title.gsub("t 恤", "t恤") + sku.brand.name + " " + sku.tags.to_s
         title = title.gsub("包邮", "").downcase
         title = title.gsub(/指定款(.*)/, '')
         algor = RMMSeg::Algorithm.new( title )
         words = []
         if title.index("t恤")
           words << "t恤"
         end
         loop do
           tok = algor.next_token
           break if tok.nil?
           #puts tok.text
           words << tok.text.force_encoding("UTF-8")
         end
        
         if true
             hit  = false
             words.reverse.each do |w|     
               #p w
               if $cc_dict.has_key?(w)
                 v = $cc_dict[w]
                 cat = Category.find_by_name(v)
                 if cat
                     sku.category_id = cat.id
                     #sku.tags = cat.name
                     #p "!!!=======hit " + sku.title + "=>" + v
                     sku.save
                     hit  =true
                     break
                 end
               end
             end
             if not hit
               p sku.tags, sku.brand.name
               p "### ===== not hit " + sku.title
               p words   
             end
         end        

         #if sku and sku.brand
         #    p sku.url
         #    if sku.category_id < 100 #and ( sku.category_id == 3 or sku.category_id == nil )
         #        sku.categorize
         #    end
         #end
     end
  end

  task :item_tagging => :environment do
     require 'rmmseg'
     #RMMSeg::Dictionary.load_dictionaries

     #add the head dictionary to the dict
     $head_dict.each do |k,v|
       if k.length>=2
         RMMSeg::Dictionary.add(k, k.length, 1)
       end
     end

     #add the labels dictionary to the dict
     $label_dict.each do |k,v|
       if k.length>=2 
         RMMSeg::Dictionary.add(k, k.length, 1)
       end
     end

     #load the sub cat dictionary.
     sub_cat_dict={}
     load_sub_cat_dict(sub_cat_dict)

     count = Sku.maximum('id').to_i
     #max=50000 #used for test purpose
     for id in (1..count+1) do
         #break if id>max
         p id
         sku= Sku.find_by_id(count-id+1)
         next if not sku
         next if sku.category_id > 100
         next if sku.from !~ /homepage/
         next unless sku.head.blank?
         #title = sku.title.gsub(" t 恤", "t桖")
         title = sku.title.gsub("包邮", "").downcase
         title = title.gsub(/指定款(.*)/, '')
         heads=[]
         labels=[]
         words = []
         algor = RMMSeg::Algorithm.new( title )
         if title.index("恤")
           words << "t恤"
         end
         loop do
           tok = algor.next_token
           break if tok.nil?
           #puts tok.text
           words << tok.text.force_encoding("UTF-8")
         end
         hit=false
         words.reverse.each do |w|
           if !hit and $head_dict.has_key?(w) 
             if true#verified_head?(w)
               heads<<w
               #hit=true
             end
           elsif $label_dict.has_key?(w)
             #p label
             labels<<w
           end
         end
         sku.tag_list=labels.uniq.join(',');
         sku.head=select_head(heads)
         unless sku.head.blank?
           if sub_cat_dict.has_key?(sku.head)
             sku.sub_cat_id=sub_cat_dict[sku.head]
             #p "*******************"
             #p sku.sub_cat_id
           end
         end
         #p "----------------------------------------------"
         #p title
         #p sku.head
         #p sku.tags
         sku.save
     end
  end

  # tag the category to skus by using synonyms.
  def load_sub_cat_dict(cat_dict)
    cat_list=Category.active
    cat_list.each do |c|
      cat_dict[c.name]=c.id
      unless c.synonym.blank?
         line=c.synonym.strip()
         words=line.downcase.split(' ')
         words.each do |w|
           cat_dict[w]=c.id
           p w
         end
      end
    end
  end

  # tag the category to skus by using synonyms.
  def load_sub_cat_dict_other(cat_dict)
    cat_list=Category.get_all_sub_categories
    cat_list.each do |c|
      cat_dict[c.name]=c.id
      unless c.synonym.blank?
        line=c.synonym.strip()
        words=line.downcase.split(' ')
        words.each do |w|
          cat_dict[w]=c.id
          p w
        end
      end
    end
  end


  task :sub_category => :environment do
    require 'rmmseg'
    #RMMSeg::Dictionary.load_dictionaries

    categories = Category.get_all_sub_categories.collect{|c| [c.name, 0] }

    #add the head dictionary to the dict
    categories.each do |k,v|
      if k.length>=2
        RMMSeg::Dictionary.add(k, k.length, 1)
      end
    end

    puts categories.inspect

    #load the sub cat dictionary.
    sub_cat_dict={}
    load_sub_cat_dict(sub_cat_dict)

    #Sku.where(:id => [173384]).find_each do |sku|
    #Sku.where("sub_category_id is nul").find_each do |sku|
    Sku.where("1=0").find_each do |sku|
      puts sku.inspect

      next if not sku
      next if sku.category_id > 100
      next if sku.from !~ /homepage/
      #title = sku.title.gsub(" t 恤", "t桖")
      title = sku.title.gsub("包邮", "").downcase
      title = title.gsub(/指定款(.*)/, '')
      heads=[]
      labels=[]
      words = []

      puts "--------------title----------"
      puts title

      algor = RMMSeg::Algorithm.new( title )
      if title.index("恤")
        words << "t恤"
      end
      loop do
        tok = algor.next_token
        break if tok.nil?
        #puts tok.text
        words << tok.text.force_encoding("UTF-8")
      end
      hit=false
      words.reverse.each do |w|
        if !hit and $head_dict.has_key?(w)
          if true#verified_head?(w)
            heads<<w
                 #hit=true
          end
        elsif $label_dict.has_key?(w)
          #p label
          labels<<w
        end
      end

      puts words
      puts "-----------------------words-----------------------"

      sku_head=select_head(heads)

      unless sku_head.blank?
        if sub_cat_dict.has_key?(sku_head)
          sku.sub_category_id=sub_cat_dict[sku_head]
        end
      end
      #p "----------------------------------------------"
      #p title
      #p sku.head
      #p sku.tags
      sku.save
    end
  end

  
  def select_head(heads)
    if heads.length<1
      ""
    elsif heads.length<2
      heads[0]
    else
      max=$head_dict[heads[0]]
      maxindex=0
      length=heads.length-1
      for i in 1..length do
        if $head_dict[heads[i]]>max
          max=$head_dict[heads[i]]
          maxindex=i
        end
      end 
        #p max
        #p maxindex
        #p "==================================="
      heads[maxindex]
    end
  end

  task :sku_classify => :environment do
     Sku.where("category_id = 3").order("created_at desc").each do |sku|
         if sku and sku.brand and sku.from =~ /homepage/
             p sku.title
             if sku.category_id < 100 #and ( sku.category_id == 3 or sku.category_id == nil )
               sku.categorize
             end
         end
     end
  end

end
