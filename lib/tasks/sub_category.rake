namespace :sub_category do

  task :go, [:sku_id] => :environment do |task, args|
    require 'rmmseg'
    #RMMSeg::Dictionary.load_dictionaries


    puts args.sku_id
    puts "==========="

    categories = Category.get_all_active_sub_categories

    #add the head dictionary to the dict
    categories.each do |c|

      k = c.name

      if k.length>=2
        RMMSeg::Dictionary.add(k, k.length, 1)
      end

      unless c.synonyms.blank?
        c.synonyms.each do |syn|

          if syn.content.length >= 2

            nk = syn.content.strip
            RMMSeg::Dictionary.add(nk, nk.length, 1)
          end

        end
      end

    end

    puts categories.inspect

    #load the sub cat dictionary.
    sub_cat_dict={}
    load_sub_cat_dict(sub_cat_dict)

    puts "----------all dictionary---------------------"
    puts "#{sub_cat_dict}"
    puts "----------all dictionary---------------------"

    three_month_ago = 3.months.ago.strftime("%Y-%m-%d %H:%M:%S")

    #Sku.where(:id => [173384]).find_each do |sku|
    #Sku.where("sub_category_id is nul").find_each do |sku|

    ids = ARGV.last.sub("sub_category:go[", "").sub("]", "").split(",")

    puts "=======Begin========="
    puts "=======#{args}======"


    unless ids.blank?
      operate_skus = Sku.where(:id => ids)
      puts "----------operate #{args.sku_id}-----"
    else
      operate_skus = Sku.where("sub_category_id = 0 and created_at > '#{three_month_ago}'")
      puts "-------opeate no sku id-----------"
    end

    operate_skus.find_each do |sku|
      puts sku.inspect

      next if not sku
      next if sku.category_id > 1000
      # next if sku.from !~ /homepage/
      #title = sku.title.gsub(" t 恤", "t桖")
      title = sku.title.gsub("包邮", "").downcase
      title = title.gsub(/指定款(.*)/, '')
      heads=[]
      words = []

      puts "--------------title----------"
      puts title

      algor = RMMSeg::Algorithm.new( title )

      loop do
        tok = algor.next_token
        break if tok.nil?
        #puts tok.text
        words << tok.text.force_encoding("UTF-8")
      end

      puts "---------get 1------------"
      puts "--------#{words.inspect}--------------"
      puts "---------get 1------------"


      unless sku.category_id.blank?

        limit_words = Category.get_all_active_sub_categories(sku.category_id).collect{|c| c.name}

        words.each do |w|
          if limit_words.include?(w)
            heads << w
          end
        end

      end


      if heads.blank?
        words.each do |w|
          if sub_cat_dict.include?(w)
            heads << w
          end
        end
      end

      puts words
      puts "-----------------------words-----------------------"
      puts heads
      puts "-------------------------heads--------------------------"


      # sku_head=select_head(heads, sub_cat_dict)

      unless heads.blank?
        sku_head = heads[0]
      end

      puts sku_head
      puts "-------------------------sku_head--------------------------"


      unless sku_head.blank?
        if sub_cat_dict.has_key?(sku_head)
          sku.sub_category_id=sub_cat_dict[sku_head]
        end
      end
      #p "----------------------------------------------"
      #p title
      #p sku.head
      #p sku.tags
      puts "========================"
      puts sku.sub_category_id

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
      heads[maxindex]
    end
  end


  # tag the category to skus by using synonyms.
  def load_sub_cat_dict(cat_dict)
    cat_list = Category.get_all_active_sub_categories
    cat_list.each do |c|
      cat_dict[c.name]=c.id
      unless c.synonyms.blank?

        c.synonyms.each do |syn|
          w = syn.content.strip
          cat_dict[w] = c.id
          puts "#{c.name} has one synonym #{syn.content}"
        end

      end
    end
  end

end