# encoding: utf-8
namespace :tags do

  task :sync_to_matter  => :environment do
    Matter.find_each do |m|
      m.sync_tags
      p m.tags
    end
  end

  task :add_tags_to_sku, [:sku_id] => :environment do |task, args|
    head_dict = []
    fn = Rails.root + "db/seed/new_tag.txt"
    cat = ""
    File.new(fn).each do |line|
      line  = line.strip()
      if line != ""
        word=line.downcase
        next if word.length == 0
        head_dict << word
      end
    end

    head_dict.each do |word|
      if word.length>=2
        RMMSeg::Dictionary.add(word, word.length, 1)
      end
    end

    #TODO
    #skus = Sku.order("id desc").limit(1)

    puts "=======Begin========="
    puts "=======#{args}======"
    ids = ARGV.last.sub("tags:add_tags_to_sku[", "").sub("]", "").split(",")


    unless ids.blank?
      operate_skus = Sku.where(:id => ids)
      puts "----------operate #{ids}-----"
    else
      operate_skus = Sku.where(["created_at > ?", 24.hours.ago])
      puts "-------opeate no sku id-----------"
    end

    operate_skus.find_each do |sku|
      title = sku.title
      desc = sku.desc

      context = "#{title} #{desc}"

      algor = RMMSeg::Algorithm.new(context)

      tags = []
      loop do
        tok = algor.next_token
        break if tok.nil?
        word = tok.text.force_encoding("UTF-8")

        if head_dict.member? word
          tags << word
        end
      end

      sku.tag_list = tags.join(",")
      if sku.save
        sku.sync_to_matters
      end
      puts sku.tag_list
      #puts sku.inspect
      puts "=========================="
    end

  end

  task :sub_category => :environment do

    sub_categories = []

    pids = Category.where(:parent_id => 1).map(&:id)

    categories = Category.where(:parent_id => pids).all.collect{|c| [c.id, c.name] }

    categories << [1004, "t恤"]

    chash = {}

    unless categories.blank?
      categories.each do |c|
        chash[c[1].to_s] = c[0]
        sub_categories << c[1]
      end
    end

    puts chash.inspect
    puts "===========chash================="

    sub_categories.each do |word|
      if word.length>=2
        RMMSeg::Dictionary.add(word, word.length, 1)
      end
    end

    puts sub_categories.inspect
    puts "==========sub_categories============"

    #TODO
    #skus = Sku.order("id desc").limit(1)

    #Sku.where("title like '%t恤%' or title like '%T恤%'").find_each do |sku|
    #where(["created_at > ?", 24.hours.ago])where(:sub_category_id => 0)
    #Sku.where(["created_at > ?", 24.hours.ago]).find_each do |sku|
    Sku.where("1=2").find_each do |sku|
    #Sku.find_each do |sku|

      puts sku.inspect
      puts "---------------------"

      title = sku.title

      desc = sku.desc

      context = "#{title}"

      algor = RMMSeg::Algorithm.new(context)

      tags = []
      loop do
        tok = algor.next_token
        break if tok.nil?
        word = tok.text.force_encoding("UTF-8")

        puts word
        puts "====================="

        if sub_categories.member? word
          tags << word
        end
      end

      puts tags.inspect

      unless tags.blank?

        if tags.member? "t恤"
          sku.sub_category_id = 1004
        else
          sku.sub_category_id = chash[tags.first.to_s]
        end
        sku.save
      end

      puts "=========================="
      puts sku.inspect
      puts "==========================="

    end

  end


  task :category => :environment do

    Sku.where("category_id = 1 or category_id is null or category_id = 3").find_each do |sku|


      puts sku.inspect
      puts "---------------------"

      title = sku.title
      desc = sku.desc
      context = "#{title} #{desc}"

      if context.include?("鞋")
        sku.category_id = 4
      elsif context.include?("裙")
        sku.category_id = 13
      elsif context.include?("裤")
        sku.category_id = 12
      elsif context.include?("包")
        sku.category_id = 5
      elsif context.include?("衫") || context.include?("衣") || context.include?("恤")
        sku.category_id = 11
      elsif context.include?("内")
        sku.category_id = 14
      end

      sku.save
      puts "=========================="
      puts sku.inspect
      puts "==========================="

    end

  end

end
