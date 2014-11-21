# -*- encoding : utf-8 -*-
$cat_dict = {}
$head_dict={}
$label_dict={}

def load_cat(dict_file_name)
    fn = Rails.root + dict_file_name
    cat = ""
    File.new(fn).each do |line|
      line  = line.strip()
      if line[0] == "*"
         cat = line[1, 20]
         #p cat
         if cat != ""
             $cat_dict[cat] = cat
         end
         next
      end
      if line != ""
         $cat_dict[line.downcase] = cat
      end
    end
end

def load_head(dict_file_name)
    fn = Rails.root + dict_file_name
    cat = ""
    File.new(fn).each do |line|
      line  = line.strip()
      if line[0] == "*"
         cat = line[1, 20]
         #p cat
         if cat != ""
             $head_dict[cat] = 1
         end
         next
      end
      if line != ""
         words=line.downcase.split(' ')
         next if words.length!=2
         $head_dict[words[0]] = words[1].to_i
      end
    end
end

def load_label(dict_file_name)
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
         words=line.downcase.split(' ')
         next if words.length!=2
         $label_dict[words[0]] = words[1].to_i
      end
    end
end

def init_cat_dict
    dict1='db/seed/tag.txt'
    load_cat(dict1)
    dict2='db/seed/label.txt'
    load_label(dict2)
    dict3='db/seed/head.txt'
    load_head(dict3)
    $cc_dict = $cat_dict
    $cat_dict = $cat_dict.sort {|a,b| b[0].length<=>a[0].length}
    #p $cat_dict
end

init_cat_dict
