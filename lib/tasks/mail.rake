# encoding: utf-8

namespace :mail do

  task :send => :environment do
     email_file  = "/var/www/shangjieba_dat/emails_new.yml"
     email_list = YAML::load_stream( File.open( email_file ) )
     #email_list=[[{"k"=>"jinglei", "v"=>"zhao.jinglei@gmail.com"},{"k"=>"lala", "v"=>"27190508@qq.com"}, {"k"=>"feng", "v"=>"fenglianren@126.com"}]]
     #email_list=[[{"k"=>"wps", "v"=>"453567320@qq.com"}, {"k"=>"hi","v"=>"xianingzhong@163.com"}, {"k"=>"hi", "v"=>"logoxzw@163.com"}]]
     total_number=1000
     i=1
     email_list.each do |ds|
       if i>total_number
         break
       end

        if i < 1000
          next
        end

       print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
       #print ds
       flag = 0
       ds.each do |d|
         print d["k"]
         print "((((((((((((((((((((((((((((((("
         name = d["k"]
         email = d["v"]

         if name == "谢娟华"
            flag = 1
         end

         if flag == 1
           unless email.blank?
             print name
             print email
             #recommend_shops=[]
             recommend_shops=Recommend.recommended_discounts
             recommend_items=Item.recommended(3)
             subject="你的闺蜜在上街吧让你帮她挑选衣服"
             print "before sending a email"
             UserMailer.invite_email_bulk(name,email, recommend_shops, recommend_items, subject ).deliver
             print "!!!sending a email !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            end
          end
       end
       i=i+1
     end
  end

  task :qunfa => :environment do
    UserMailer.qunfa_mail.deliver
  end

  task :qixi => :environment do
    email_file  = "/var/www/shangjieba_dat/emails_new.yml"
    email_list = YAML::load_stream( File.open( email_file ) )
    #email_list=[[{"k"=>"jinglei", "v"=>"zhao.jinglei@gmail.com"},{"k"=>"lala", "v"=>"27190508@qq.com"}, {"k"=>"feng", "v"=>"fenglianren@126.com"}]]
    #email_list=[[{"k"=>"wps", "v"=>"453567320@qq.com"}, {"k"=>"hi","v"=>"xianingzhong@163.com"}, {"k"=>"hi", "v"=>"logoxzw@163.com"}]]
    total_number=100000
    i=0
    email_list.each do |ds|
      if i>total_number
        break
      end

      puts "-------ready go--------"

      ds.each do |d|
	      puts "-------#{i}---#{d["k"]}--------#{d["v"]}--------------"
        name = d["k"]
        email = d["v"]

        unless email.blank?
          #recommend_shops=[]
          recommend_shops=Recommend.recommended_discounts
          recommend_items=Item.recommended(3)
          subject="七夕全城热恋，尽享实惠好去处"
          puts "------before send email--#{name}--#{email}------------------"
          UserMailer.invite_qixi_email_bulk(name,email, recommend_shops, recommend_items, subject ).deliver
          puts "------send email over--#{name}--#{email}--------------------"
        else
          puts "--------------email is nil----------------------------------"
        end

        i=i+1

      end

    end
  end

  task :eight_twenty_two => :environment do
    email_file  = "/var/www/shangjieba_dat/emails_082204.yml"
    #email_list = YAML::load_stream( File.open( email_file ) )
    email_list=[[{"k"=>"zl", "v"=>"453567320@qq.com"}, {"k"=>"hi","v"=>"2218408443@qq.com"}]]
    total_number=100000
    i=0
    email_list.each do |ds|
      if i>total_number
        break
      end
      puts "-------ready go--------"
      ds.each do |d|
		      puts "-------#{i}---#{d["k"]}--------#{d["v"]}--------------"
        	name = d["k"]
        	email = d["v"]

        	unless email.blank?
          		subject="[逛街攻略]MM开学季,省钱有诀窍，美丽不打折"
          		puts "------before send email--#{name}--#{email}------------------"
          		UserMailer.eight_twenty_two(email, subject).deliver
          		puts "------send email over--#{name}--#{email}--------------------"
        	else
          		puts "--------------email is nil----------------------------------"
        	end
		      sleep(5)
		      i = i + 1
	    end
       
    end
  end

  task :mm_kaixue => :environment do
    email_file  = "/var/www/shangjieba_dat/emails_08_01.yml"
    email_list = YAML::load_stream( File.open( email_file ) )
    #email_list=[[{"k"=>"zl", "v"=>"453567320@qq.com"}, {"k"=>"hi","v"=>"2218408443@qq.com"}]]
    total_number=100000
    i=0
    email_list.each do |ds|
      if i>total_number
        break
      end
      puts "-------ready go--------"
      ds.each do |d|
        puts "-------#{i}---#{d["k"]}--------#{d["v"]}--------------"
        name = d["k"]
        email = d["v"]
        unless email.blank?
          subject="[逛街攻略]MM开学季，萝莉风尚标，萝莉要实惠"
          puts "------before send email--#{name}--#{email}------------------"
          UserMailer.eight(email, subject).deliver
          puts "------send email over--#{name}--#{email}--------------------"
        else
          puts "--------------email is nil----------------------------------"
        end
        sleep(15)
        i = i + 1
      end
    end
  end


end
