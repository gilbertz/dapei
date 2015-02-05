# -*- encoding : utf-8 -*-

class CollocationsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:like_matters, :publish, :stats_record, :template_publish, :set_draft, :delete_thing, :delete_matter]

  # 取消喜欢
  def delete_thing
    pr = JSON.parse(params["request"])

    tid = pr["tid"]

    @m = Matter.find_by_image_name(tid)

    @like = Like.where(:user_id => current_user.id, :target_id => @m.id, :target_type => "Matter").first
    @like.destroy
    respond_to do |format|
      format.json { render :json=>{:result=>"0"} }
    end
  end

  
  def delete_matter
    pr = JSON.parse(params["request"])

    tid = pr["tid"]

    @m = Matter.find_by_image_name(tid)
    #p @m 
    if current_user and current_user.can_be_admin
      @m.destroy
    end
    respond_to do |format|
      format.json { render :json=>{:result=>"0"} }
    end
  end


  def app_template

    unless user_signed_in?
      redirect_to new_user_session_path
      return
    end

    @rule_categories = Category.where("thing_img_id is not null").all
    render :layout => false
  end

  def template_publish
    pr = JSON.parse(params["request"])

    @dt = DapeiTemplate.new
    @dt.user_id = current_user.id
    @dt.description = pr["description"]
    @dt.title = pr["title"]

    spec_uuid = rand_str(20)
    @dt.spec_uuid = spec_uuid

    @dt.save

    #计算旋转图像的宽高
    pr["items"].each do |i|
      unless i["transform"].blank? or i["transform"] == [1,0,0,1]

        if i["type"] == "ph"
          image_root = "#{Photo::Sjb_root}/app/assets/images/polyvore/f7f7f7.png"
          i["thing_id"] = "f7f7f7"
        elsif i["type"] == "image"
          image_root = get_img_path(i)  
        end

        c = i["transform"][0]
        s = i["transform"][1]

        rotate_value = Math.acos(c) * 180 / Math::PI

        if s > 0
          rotate_value = rotate_value
        elsif s < 0
          rotate_value = 360.00 - rotate_value
        end

        #图片旋转处理程序目录
        image_dispose_int = "/var/ImageDispose/imrotate"

        image_root_rotate_dir = "/var/tmp/#{i["thing_id"]}"
        image_root_rotate_file = "/var/tmp/#{i["thing_id"]}.png"
        image_root_rotate_file_resize = "/var/tmp/resize/#{i["thing_id"]}.png"

        #缩放图片
        image_tmp = MiniMagick::Image.open(image_root)
        image_tmp.resize "#{i["w"]}x#{i["h"]}!"

        image_tmp.write image_root_rotate_file_resize

        r = `cd #{image_dispose_int} && ./imrotate #{image_root_rotate_file_resize} #{rotate_value} #{image_root_rotate_dir}`

        image_tmp_b = MiniMagick::Image.open(image_root_rotate_file)
        w = image_tmp_b[:width]
        h = image_tmp_b[:height]

        new_x = (i["w"] - w)/2
        new_y = (i["h"] - h)/2

        i["ww"] = i["w"]
        i["hh"] = i["h"]
        i["w"] = w
        i["h"] = h

        i["xx"] = i["x"]
        i["yy"] = i["y"]

        i["x"] = i["x"] + new_x
        i["y"] = i["y"] + new_y

      end
    end

    x_arr = pr["items"].collect{|i| i["x"].to_f }.to_a
    y_arr = pr["items"].collect{|i| i["y"].to_f }.to_a

    wx_arr = pr["items"].collect{|i| i["w"].to_f + i["x"].to_f }.to_a
    hy_arr = pr["items"].collect{|i| i["h"].to_f + i["y"].to_f }.to_a

    smallest_x = x_arr.min
    biggest_wx = wx_arr.max

    smallest_y = y_arr.min
    biggest_hy = hy_arr.max

    big_w = biggest_wx - smallest_x
    big_h = biggest_hy - smallest_y

    biggest = [big_h, big_w].max
    minest = [big_h, big_w].min

    resize_l = 600.000 / biggest

    space_h = (600 - big_h * resize_l) / 2
    space_w = (600 - big_w * resize_l) / 2

    items = pr["items"]
    unless items.blank?
      1.upto(items.length-1) do |i|
        (items.length-i).times do |j|
          if items[j]["z"].to_i > items[j+1]["z"].to_i
            items[j],items[j+1] = items[j+1],items[j]
          end
        end
      end
    end

    bg_dir = "#{Photo::Sjb_root}/app/assets/images/newweb/bg600.jpg"
    image = MiniMagick::Image.open(bg_dir)

    template_dir = "#{Photo::Sjb_root}/public/cgi/img-set/id/#{spec_uuid}/size/"
    template_file = "#{template_dir}s.jpg"

    unless items.blank?
      items.each do |i|

        x = (i["x"].to_f - smallest_x) * resize_l + space_w
        y = (i["y"].to_f - smallest_y) * resize_l + space_h
        w = i["w"].to_f * resize_l
        h = i["h"].to_f * resize_l
        z = i["z"]

        unless i["transform"].blank? or i["transform"] == [1,0,0,1]
          data_x = i["xx"].to_f - smallest_x
          data_y = i["yy"].to_f - smallest_y

          data_w = i["ww"]
          data_h = i["hh"]
        else
          data_x = i["x"].to_f - smallest_x
          data_y = i["y"].to_f - smallest_y

          data_w = i["w"]
          data_h = i["h"]
        end

        unless i["transform"].blank?
          transform = i["transform"].join(",")
        else
          transform = ""
        end

        if i["type"] == "ph"

          ti = @dt.template_items.build(x: data_x, y: data_y, w: data_w, h: data_h, z: z, item_type: i["type"], transform: transform, dropHint: i["dropHint"], visible_ratio: i["visible_ratio"])
          ti.save

          #----------合成旋转的占位图像------------------
          unless i["transform"].blank?
            c = i["transform"][0]
            s = i["transform"][1]

            image_root = "#{Photo::Sjb_root}/app/assets/images/polyvore/f7f7f7.png"
            i["thing_id"] = "f7f7f7"

            rotate_value = Math.acos(c) * 180 / Math::PI

            if s > 0
              rotate_value = rotate_value
            elsif s < 0
              rotate_value = 360.00 - rotate_value
            end

            #图片旋转处理程序目录
            image_dispose_int = "/var/ImageDispose/imrotate"

            image_root_rotate_dir = "/var/tmp/#{i["thing_id"]}"
            image_root_rotate_file = "/var/tmp/#{i["thing_id"]}.png"
            image_root_rotate_file_resize = "/var/tmp/resize/#{i["thing_id"]}.png"

            #缩放图片
            image_tmp = MiniMagick::Image.open(image_root)
            image_tmp.resize "#{i["ww"]}x#{i["hh"]}!"
            image_tmp.write image_root_rotate_file_resize

            r = `cd #{image_dispose_int} && ./imrotate #{image_root_rotate_file_resize} #{rotate_value} #{image_root_rotate_dir}`

            #图片旋转处理程序目录
            image_root_rotate_file = "/var/tmp/#{i["thing_id"]}.png"

            image_root = image_root_rotate_file

          end

          image.draw "image over #{x},#{y} #{w},#{h} '#{image_root}'"
          newx = x + (w/2)
          newy = y + (h/2)

          newx = format("%.2f", newx).to_f
          newy = format("%.2f", newy).to_f

          image.draw "text #{newx},#{newy} '#{i["dropHint"]}'"
        elsif i["type"] == "image"

          ti = @dt.template_items.build(x: data_x, y: data_y, w: data_w, h: data_h, z: z, item_type: i["type"], transform: transform, thing_id: i["thing_id"], oa: i["oa"], masking_policy: i["masking_policy"], mask_dirty: i["mask_dirty"], mask_id: i["mask_id"], opacity: i["opacity"], title: i["title"], url: i["url"], displayurl: i["displayurl"], display_price: i["display_price"], visible_ratio: i["visible_ratio"])
          ti.save

          image_root = get_img_path(i)

          unless i["transform"].blank?
            c = i["transform"][0]
            s = i["transform"][1]

            rotate_value = Math.acos(c) * 180 / Math::PI

            if s > 0
              rotate_value = rotate_value
            elsif s < 0
              rotate_value = 360.00 - rotate_value
            end

            #图片旋转处理程序目录
            image_root_rotate_file = "/var/tmp/#{i["thing_id"]}.png"

            image_root = image_root_rotate_file

          end

          image.draw "image over #{x},#{y} #{w},#{h} '#{image_root}'"
          newx = x + (w/2)
          newy = y + (h/2)
          image.draw "text #{newx},#{newy} '#{i["dropHint"]}'"
        end

      end
    end

    unless Dir.exist?(template_dir)
      FileUtils.mkdir_p(template_dir)
    end

    image.write template_file
    format.json { render :json=>{:result=>"0"} }
  end

  def edit
    render :layout => "home_2013"
  end

  def new
    @hot_recommend = Matter.where("is_cut = 1").order("id desc").limit(30)

    shangzhuang_categories = RuleCategory.where("father_id = 1").all.collect{|rc| rc.id }
    @shangzhuang = Matter.where("is_cut = 1 and category_id in (#{shangzhuang_categories.join(',')})").limit(30)

    xiazhuang_categories = RuleCategory.where("father_id = 2").all.collect{|rc| rc.id }
    @xiazhuang = Matter.where("is_cut = 1 and category_id in (#{xiazhuang_categories.join(',')})").limit(30)
    render :layout => "home_2013"
  end

  def get_brands
    #@brands = Brand.where("level >= 4").order("url asc")
    #brands = []
    #s = Searcher.new("", "matter", "")
    #s.getBrandGroup
    #s.get_bg.each do |d|
    #  brands << d['brand_id'] if d['brand_id'].to_i > 0
    #end

    #注意brand_id 的数量 好像最多能查2000？ 以后如果品牌多的话会报错

    #@brands = Brand.find_all_by_id( brands)
    #@brands = @brands.sort_by{|b| b.url}
  end


  def get_matter_categories
    @rule_categories = Category.where("id > 10 and thing_img_id is not null").where( :is_active => true )
    @rule_categories += Category.where("id > 3 and id <= 10 and thing_img_id is not null").where( :is_active => true )
    @rule_categories += Category.where("id = 3").where( :is_active => true )

    @sucai_categories = Category.where("id > 10 and parent_id = 1140").where(:is_active => true).order("weight desc")

    if @su
      @user_categories =  Category.by_user(@su.id)
    end    

    @user = @su
    get_brands
  end


  def get_app_categories
    @rule_categories = Category.where("id > 10 and thing_img_id is not null").where( :is_active => true )
    @rule_categories += Category.where("id > 3 and id < 10 and thing_img_id is not null").where( :is_active => true )
    @rule_categories += Category.where("id = 3").where( :is_active => true )

    @sucai_categories = Category.where("id > 10 and parent_id = 1140").where(:is_active => true).order("weight desc")
    @home_categories = Category.where("parent_id = 10").where(:is_active => true).order("weight desc")
    #@user_categories =  Category.where(:user_id => @su.id).where(:is_active => true).order("weight desc")   
    if @su
      @user_categories =  Category.by_user(@su.id)
    end   

    @user = @su
  end


  def index
    get_matter_categories
   
    unless params[:tmp].blank?
      render :template => "collocations/#{params[:tmp]}", :layout => "home_2013"
      return
    end

    unless user_signed_in?
      redirect_to new_user_session_path
      return
    end

    render :layout => false
  end


  def price_ranges
    respond_to do |format|
      format.json
    end
  end

  def category_id_titles
    get_matter_categories

    respond_to do |format|
      format.json
    end
  end

  def categories
    get_app_categories

    respond_to do |format|
      format.json
    end
  end

  def editor
    respond_to do |format|
      format.json
    end
  end

  def template_load

    r = JSON.parse(params["request"])

    @dapei_template = DapeiTemplate.find(r["id"])

    respond_to do |format|
      format.json
    end
  end

  def editor_things
    response.headers["Content-Type"] = 'application/json'

    # fragment cache 2 hours
    r = JSON.parse(params["request"])
    @cache_key = r.to_s
    @sub_categories = []

    #res_dict = Rails.cache.fetch "k_#{@cache_key}", :expires_in => 15.minutes do 
      result_dict = {}
      if r["category_id"]
        @sub_categories = []
        unless r["category_id"] == "10000"
          cat  = Category.find_by_id(r["category_id"])
          if true 
            @current_category_name = cat.name
            if Category.is_sub(cat.id)
              @sub_categories = Category.sub(cat.parent_id)
            else
              @sub_categories = Category.sub(cat.id)
            end
          end

          #for specified shop user
          if cat.user
            r["sub_category_id"] = r["category_id"]  
            r["category_id"] = nil
          elsif @su.is_shop 
            r['exclude_user_id'] = @su.id
          end

        else
          user_id = @su.id
        end
      end

      unless r["price_int"].blank?
        price = r["price_int"].split(",")
      end

      if true
        q = r["query"]
        l = r["length"]
        p = r["page"]
        s = Searcher.new("matter", query = q, nil, limit = l, page = p)
        s.set_category_id(r['category_id']) if r['category_id']
        s.set_color(r["color"]) if r["color"]
        s.set_brand(r["brand_id"]) if r["brand_id"]
        s.set_sub_category_id(r["sub_category_id"]) if r["sub_category_id"] and  r["sub_category_id"].to_i != 0
        s.set_user_id(user_id) if user_id
        s.set_exclude_user_id(r['exclude_user_id']) if r['exclude_user_id']
        #s.remove_level(1)
        #s.set_level(0)

        unless price.blank?
          s.set_price(price[0], price[1])
        end

        @matters = s.search()

        s.getBrandGroup
        brands = []
        s.get_bg.each do |d|
          brands << d['brand_id'] if d['brand_id'].to_i > 0
        end
        @brands = Brand.find_all_by_id(brands).sort_by{|b| b.url}
        
        result_dict[:matters] = @matters
        result_dict[:brands] = @brands
        result_dict[:sub_categories] = @sub_categories  
        result_dict[:current_category_name] = @current_category_name
      end
    #  return result_dict
    #end
    res_dict = result_dict
    
    @matters = res_dict[:matters]
    @brands =  res_dict[:brands]
    @sub_categories = res_dict[:sub_categories]
    @current_category_name = res_dict[:current_category_name]

    respond_to do |format|
      format.json
    end
  end

  def mystuff_things
    r = JSON.parse(params["request"])

    @likes = Like.where(:target_type => "Matter", :user_id => current_user.id).paginate(:per_page => r["length"], :page => r["page"])

    likes = @likes.uniq.pluck(:target_id)

    @matters = Matter.where(:id => likes)

    respond_to do |format|
      format.json
    end
  end

  
  def like_matters
    @user = current_user
    @limit = 10
    @page = 1
    @page = params[:page].to_i if params[:page]
    @limit = params[:page].to_i if params[:limit]

    @matters = Matter.liked_by(@user).uniq.page(@page).per(@limit)
    @total_count = Matter.liked_by(@user).uniq.count 
    @total_pages  = (@total_count - 1) / @limit + 1
    respond_to do |format|
      format.json
    end 
  end


  def sponsored_things
    respond_to do |format|
      format.json
    end
  end

  def templates

    pr = JSON.parse(params[:request])

    @dapei_templates = DapeiTemplate.paginate(page: pr["page"], per_page: pr["length"]).order("id desc")

    respond_to do |format|
      format.json
    end
  end

  def valid(i)
    if i["thing_id"].present? or i['type'] == 'text' or  i['type'] == 'image64' or  i['type'] == 'image_url'
      return true
    else
      return false
    end
  end

  def save_draft(pr, dp_id=nil)
      items = pr["items"]
      items = items_sort_by_z(items)

      unless current_user.blank?
        uid = current_user.id
      else
        uid = 0
      end

      tmp_image_dir = "/var/tmp/tmp_image/#{uid}/"
      unless Dir.exist?(tmp_image_dir)
        FileUtils.mkdir_p(tmp_image_dir)
        `chmod -R 1777 #{tmp_image_dir}`
        puts "--------------- create dir #{tmp_image_dir}---------------"
      end

      tmp_dir = "/var/tmp/#{uid}/"
      unless Dir.exist?(tmp_dir)
        FileUtils.mkdir_p(tmp_dir)
        `chmod -R 1777 #{tmp_dir}`
        puts "--------------- create dir #{tmp_dir}---------------"
      end

      tmp_resize_dir = "/var/tmp/resize/#{uid}/"
      unless Dir.exist?(tmp_resize_dir)
        FileUtils.mkdir_p(tmp_resize_dir)
        `chmod -R 1777 #{tmp_resize_dir}`
        puts "--------------- create dir #{tmp_resize_dir}---------------"
      end

      spec_uuid = rand_str(20)
      original_id = pr["id"]
      
      #thing_ids = items.collect{|i|i["thing_id"]}
      #checksum = "#{uid}:"+thing_ids.sort.join('_')      
      @dpi = DapeiInfo.new({category_id: pr["category_id"], dapei_id: dp_id,  user_id: uid, spec_uuid: spec_uuid, is_show: 0, original_id: original_id})

      unless pr["basedon_tid"].blank?
        @dpi.basedon_tid = pr["basedon_tid"]
      end

      #计算旋转图像的宽高等信息
      items = dispose_items(items, uid)

      x_arr = items.collect{|i| i["x"].to_f }.to_a
      y_arr = items.collect{|i| i["y"].to_f }.to_a

      wx_arr = items.collect{|i| i["w"].to_f + i["x"].to_f }.to_a
      hy_arr = items.collect{|i| i["h"].to_f + i["y"].to_f }.to_a

      smallest_x = x_arr.min
      biggest_wx = wx_arr.max

      smallest_y = y_arr.min
      biggest_hy = hy_arr.max

      big_w = biggest_wx - smallest_x
      big_h = biggest_hy - smallest_y

      biggest = [big_h, big_w].max

      resize_l = 600 / biggest

      l_y = (600 - big_h * resize_l) / 2
      l_x = (600 - big_w * resize_l) / 2

      bg_dir = "#{Photo::Sjb_root}/app/assets/images/newweb/bg600.jpg"
      image = MiniMagick::Image.open(bg_dir)
      @dpi.width = big_w
      @dpi.height = big_h
      dir = Time.now.strftime("%Y%m%d")
      @dpi.dir = dir  

      @dpi.save
     
      items.each_with_index do |i, index|
        if valid(i)
          if true
            x = (i["x"].to_f - smallest_x) * resize_l
            y = (i["y"].to_f - smallest_y) * resize_l
            w = i["w"].to_f * resize_l
            h = i["h"].to_f * resize_l

            image_root = get_img_path(i)
            matter = Matter.find_by_image_name(i['thing_id'])
            next unless matter
            matter_id = matter.id

            unless i["mask_spec"].blank? and i['template_spec'].blank?

              puts "#{i['mask_spec']}---spec"

              spec_json = i["mask_spec"]

              spec_arr = []
              unless spec_json.blank?
                  spec_json.each do |sj|
                      spec_arr << sj["x"].to_f
                      spec_arr << sj["y"].to_f
                  end
                  tspec = spec_arr.join(" ")
              else
                  tspec = "#{i['template_spec']['template_id']} #{i['template_spec']['x']} #{i['template_spec']['y']} #{i['template_spec']['scale']}"
              end

              mask_spec = MaskSpec.find_all_by_matter_id_and_mask_spec(matter_id, tspec).last

              unless mask_spec.blank?
                new_name_png = "#{mask_spec.mask_spec_image_name}.png"
                #image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
                image_root = get_mask_spec_image( new_name_png )
              else
                #TODO
              end
            end

            puts "------before----------x:#{x}---------y:#{y}---------w:#{w}-----h:#{h}---------------"

            unless i["transform"].blank?

              transform_str = i["transform"].join(" ")

              #图片旋转处理程序目录
              #image_dispose_int = "/var/ImageDispose/imrotate"
              #
              #image_root_rotate_dir = "/var/tmp/#{i["thing_id"]}"
              image_root_rotate_file = "#{tmp_dir}#{i["thing_id"]}#{index}.png"
              #
              #puts "cd #{image_dispose_int} && ./imrotate #{image_root} #{rotate_value} #{image_root_rotate_dir}"

              #`cd #{image_dispose_int} && ./imrotate #{image_root} #{rotate_value} #{image_root_rotate_dir}`

              image_root = image_root_rotate_file
            end

            puts "------after----------x:#{x}---------y:#{y}---------w:#{w}-----h:#{h}---------------"
            puts "image over #{x},#{y} #{w},#{h} '#{image_root}'"

            x = x + l_x
            y = y + l_y

            begin
              image.draw "image over #{x},#{y} #{w},#{h} '#{image_root}'"
            rescue => e
              p e.to_s
            end


            if true
              matter_id = nil
              matter_id = matter.id if matter
              i = @dpi.dapei_item_infos.build(x: i['ox'], y: i['oy'], w: i['ow'], h: i['oh'], z: i["z"], matter_id: matter_id, mask_spec: i["spec_str"].to_s, bkgd: i["bkgd"], item_type: i["type"], thing_id: i["thing_id"], transform: transform_str )
              i.save
              if matter.brand
                @dpi.add_brand_tag(matter, (x+ 1/2*w).to_i, (y+1/2*h).to_i )
              end
            end
          end
        end
      end
  
      if dp_id and dp_id.to_i > 0
        new_image_dir = "#{Photo::Sjb_root}/public/cgi/img-set/cid/#{dir}/#{dp_id}/id/#{spec_uuid}/size/"

        unless Dir.exist?(new_image_dir)
          FileUtils.mkdir_p(new_image_dir)
        end

        img_name = "y.jpg"
        image.write "#{new_image_dir}#{img_name}"

        img_name_small = "m.jpg"
        image.resize "150x150"
        image.write "#{new_image_dir}#{img_name_small}"

        img_s_small = "s.jpg"
        image.write "#{new_image_dir}#{img_s_small}"
      
      else
        new_image_dir_two = "#{Photo::Sjb_root}/public/cgi/img-set/id/#{dir}/#{spec_uuid}/size/"
        unless Dir.exist?(new_image_dir_two)
         FileUtils.mkdir_p(new_image_dir_two)
         `chmod -R 1777 #{new_image_dir_two}`
         puts "--------------- create dir #{new_image_dir_two}---------------"
        end

        img_s_small_two = "s.jpg"
        image.write "#{new_image_dir_two}#{img_s_small_two}"
      end
      return @dpi
  end


  def set_draft
      pr = {}
      pr = parse_request
      
      save_draft( pr )

      respond_to do |format|
        format.json
      end
      
  end


  def parse_request
    begin
      return JSON.parse(params[:request])
    rescue => e
      return params[:request]
    end
  end

  def publish
    pr = {}
    pr = parse_request   
 
    is_mobile = false
    is_mobile = true if params[:token]
    if pr["title"] == ""
      if current_user.name
        pr["title"] = current_user.name
      else
        pr["title"] = "搭配秘书"
      end
    end

    # tmp_desc=""
    # pr["title"].match(/([.|,|，|;|!|！|。|．|。])+?/)
    # if $1.present?
    #    pr["title"], tmp_desc = pr["title"].split($1)
    # end
    # pr["description"]=tmp_desc unless tmp_desc.blank?
    

    tmp_desc=""
    title = ""
    title = title +pr["title"]
    pr["title"].match(/([.|,|，|;|!|！|。|．|。])+?/)
    if $1.present?
      pr["title"] = pr["title"].split($1).first
      size = pr["title"].size+1
      tmp_desc = title[size,title.size]
    end
    pr["description"]=tmp_desc unless tmp_desc.blank?

    unless current_user.blank?
      uid = current_user.id
    else
      uid = 0
    end 

    @dapei = Dapei.new({title: pr["title"], desc: pr["description"].to_s, user_id: uid, category_id: "1001"})
    #@dapei = Dapei.new({user_id: uid, category_id: "1001"})
    if @dapei.save
      tags = ""
      tags = pr['tags'].join(',') if pr['tags']

      dpi = save_draft(pr, @dapei.id)
      dpi.is_show = 0
      dpi.description = tags
      dpi.save!
    end

    # regex = /([.|,|，|;|!|！|。|．|。])+?/
    # index = regex=~pr["title"]
    # if index 
    #   @dapei.title = pr["title"].slice!0,index
    #   @dapei.desc = pr["title"].slice!1,pr["title"].size
    # else
    #   @dapei.title ="爱make,爱生活"
    #   @dapei.desc = pr["title"]
    # end
    # @dapei.save

    @dapei.show_date = @dapei.created_at
    unless @dapei.dapei_info 
      @dapei.dapei_info_flag = 1
    end
    @dapei.save

    @dapei.make_share_img
    #FlashBuy::Api.add_coin(@dapei,"publish_dapei")
    #@dapei.find_brands
    respond_to do |format|
      if is_mobile
        format.json { render_for_api :dapei_detail, :json=>@dapei, :meta=>{:result=>"0"} }
      else
        format.json
      end
    end
  end

  def show
    if params[:id].to_i == 2

      @dapei_info = DapeiInfo.last

      render :template => "collocations/show2", :layout => false
      return
    end

    render :layout => false
  end

  def stats_record
    respond_to do |format|
      format.json
    end
  end

  def collection_load
    respond_to do |format|
      format.json
    end
  end

  def embed_html
    respond_to do |format|
      format.json
    end
  end

  def tag_trends
    respond_to do |format|
      format.json
    end
  end

  def cgi_set_load
    pr = parse_request
    pr["did"] = pr["did"].to_s

    if pr["did"].present? and pr["did"].first == "-"
      @diid = pr["did"].sub("-", "")
      @dapei_info = DapeiInfo.find(@diid)
    else
      dapei = Dapei.find(pr["id"])
      @dapei_info = dapei.dapei_info 
    end

    respond_to do |format|
      format.json
    end

  end

  def cgi_set

    if params[:id].blank?
      redirect_to "/dapeis/index_all"
      return
    end

    dp = Dapei.find(params[:id])
    redirect_to dapei_view_path(dp)
  end

  def comment_add
    respond_to do |format|
      format.json
    end
  end

  def item 
    respond_to do |format|
      format.json
    end
  end

  def collection_get
    respond_to do |format|
      format.json
    end
  end


  def mystuff_sets
    pr = {}
    pr = parse_request

    @current_page = pr["page"] || 1
    @limit = pr["length"].to_i || 10   

    con = ""

    unless params[:star_dapei].blank?
      con += "dapei_infos.is_star = 1"
    else
      con = "items.user_id = #{current_user.id} and items.category_id = 1001"
    end

    @dapeis = Dapei.includes(:dapei_info).where("items.deleted is null").where(con).order("items.created_at desc").paginate(:per_page => pr["length"], :page => pr["page"])
    render :layout => false
  end

  #保存的草稿
  def mystuff_drafts
    pr = {}
    pr = parse_request  
    @current_page = pr["page"] || 1 
    @limit = pr["length"].to_i || 10

    @drafts = DapeiInfo.where("dapei_id is null").where(:user_id => current_user.id ).where(:is_show => 0).order("created_at desc").paginate(:per_page => pr["length"], :page => pr["page"])
    respond_to do |format|
      format.json
    end

  end

  #我的模版
  def mystuff_templates
    pr = parse_request 
    @current_page = pr["page"] || 1

    @dapei_templates = DapeiTemplate.where(:user_id => current_user.id).paginate(:per_page => pr["length"], :page => pr["page"])
    render :layout => false
  end

  #喜欢
  def favorite_add_thing
    pr = JSON.parse(params[:request])

    id = pr["tid"]

    m = Matter.find_by_image_name(id)

    unless m.blank?

      #TODO

    end

  end

  def get_masks
    pr = JSON.parse(params[:request])

    tid = pr["tid"]

    matter = Matter.find_by_image_name(tid)

    @mask_specs = []
    #@mask_specs = MaskSpec.includes(:matter).where(:matter_id => matter.id).order("id desc").limit(10)

  end


  def cut_templates 
    templates = []
    (1..14).each do |i|
        path = "http://qingchao1.qiniudn.com" + "/uploads/template_cut_new/#{i}.png"
        #if FileTest::exist?(path)
        #    image = MiniMagick::Image.open( path )
        #end
        #w = image[:width].to_i
        #h = image[:height].to_i 
        w = 360
        h = 360
        templates << {id:i, img_url: path, w: "#{w}", h: "#{h}" }
    end
    render :json => { templates: templates }
  end

  def mask_spec
    spec = params[:spec]
    tid = params[:tid]
    template_id = params[:template_id]

    if params[:template_id]
      x = params[:x] if params[:x]
      y = params[:y] if params[:y]
      scale = params[:scale] if params[:scale]
      tspec = "#{tid} #{x} #{y} #{scale}"
    end

    unless params[:spec].blank?
      spec_json = JSON.parse(spec) if spec
      p spec_json

      unless spec_json.is_a?(Array)
        spec_json = JSON.parse(URI.decode(spec_json))
      end
    end

    spec_arr = []
    unless spec_json.blank?
      spec_json.each do |sj|
        spec_arr << sj["x"].to_f
        spec_arr << sj["y"].to_f
      end
    end

    if template_id
      mask_spec = MaskSpec.joins(:matter).where("`matters`.image_name = ? and `mask_specs`.mask_spec = ?", tid, tspec).last
      tspec = "#{template_id} #{x} #{y} #{scale}"
    else
      tspec = spec_arr.join(" ")
      mask_spec = MaskSpec.joins(:matter).where("`matters`.image_name = ? and `mask_specs`.mask_spec = ?", tid, tspec).last
    end

    need_mask = true
    if not mask_spec.blank?
      new_name_png = "#{mask_spec.mask_spec_image_name}.png"
      to_image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
      if not FileTest::exist?(to_image_root)
           url =  AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
           `wget #{url} -O #{to_image_root}`

      end
      if File.size(to_image_root) > 512
        need_mask = false

        redirect_to  AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
        return
        #data=File.new(to_image_root, "rb").read
        #send_data(data, :filename => new_name_png, :type => "image/png", :disposition => "inline")
      end

      unless File.exist?(to_image_root)
        need_mask = true
      end

    end
    
    if need_mask 
      matter = Matter.find_by_image_name(tid)

      if true
        #cut_dir = "/var/ImageDispose/cut_with_points"
        cut_dir = "/var/ImageDispose/cut_with_points1"
        image_dispose_cut = "/var/ImageDispose/template_cut"

        #new_str = Time.now.to_i.to_s + ((100..999).to_a.shuffle[0].to_s)
        new_str =  tid[-5,5] + "_" + Time.now.to_i.to_s  
        new_name_png = new_str + ".png"

        to_image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"

        orign_image = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{tid}.png"
      
        if not FileTest::exist?(orign_image)
          url = AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{tid}.png"
          `wget #{url} -O #{orign_image}`
        end

        if template_id
          template_img = "/data/uploads/template_cut_new/#{params[:template_id]}.png" 

          `cd #{image_dispose_cut} && ./template_cut #{orign_image} #{template_img} #{to_image_root} #{x} #{y} #{scale}`
        else
          begin
            data = "cd #{cut_dir} && ./cutwithpoints tspec #{orign_image} #{to_image_root}"
            env['exception_notifier.exception_data'] = {:data=>{:user=>data , :deploy=>Rails.env}}

            `cd #{cut_dir} && ./cutwithpoints #{tspec} #{orign_image} #{to_image_root}`
          rescue =>e

            `rm #{orign_image}`
          end
        end

        mask_spec = MaskSpec.new(:matter_id => matter.id, :mask_spec => tspec, :mask_spec_image_name => new_str)
        mask_spec.save

        redirect_to AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
        return

        #data=File.new(to_image_root, "rb").read
        #send_data(data, :filename => new_name_png, :type => "image/png", :disposition => "inline")
      end
    end
  end

  def save_mask

  end


  def user_hastags

    @dapei_tags = DapeiTag.all

    respond_to do |format|
      format.json
    end
  end

  def user_tagging
    render :nothing => true
  end


  def publish_dapei_tags
    @dapei_tag_group =[]
    [[1, 5], 0].each do |i|
       doc = {}
       doc['tid'] = i
       doc['name'] = "主题"
       doc['name'] = "风格" if i==0
       doc['tags'] = DapeiTag.where(:is_hot => 1).where( :tag_type => i)
       @dapei_tag_group  << doc
    end

    respond_to do |format|
      format.json { render :json => @dapei_tag_group }
    end

  end

  def dapei_themes
    @page = 1
    @page = params[:page].to_i if params[:page]
    @limit = 8
    @limit = params[:limit].to_i if params[:limit]
    @main_tags = DapeiTag.where( :parent_id => 99 ).where( :is_hot => true ).order("created_at desc").page(@page).per(@limit)

    @total_page = @main_tags.total_pages

    respond_to do |format|
      format.html { render :layout => false }
      format.json { render_for_api :public, :json => @main_tags, :meta=>{:result=>"0"} }
    end
  end

  def hot_dapei_tags
  
    @dapei_tags = DapeiTag.where(:is_hot => 1).where( :tag_type =>[1,5,2,3,0,4] ) 
    @types = {0 => "风格", 1 => "场合", 2 => "款式", 3 => "色系", 4=>"元素", 5 => "身材"}

    @dapei_tag_group =[]
    [1, 5, 0].each do |i|
       doc = {}
       doc['tid'] = i
       doc['name'] = @types[i]
       doc['tags'] = DapeiTag.where(:is_hot => 1).where( :tag_type => i)
       @dapei_tag_group  << doc
    end
 
    @main_tags = DapeiTag.where( "parent_id is null or parent_id=0" ).where(:is_hot => true)
   
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render_for_api :public, :json => @main_tags, :meta=>{ :result=>"0", :banner =>  DapeiTag.get_banner.avatar_url  } }
    end

  end
 
  def text2image1
      require 'RMagick'
      text_dict = {
        :size => '200x',
        :pointsize => 50,
        :font => '',
        :bg_color => 'white'
      }

      text_dict[:size] = params[:size] if params[:size]
      text_dict[:pointsize] = params[:pointsize] if params[:pointsize]
      text_dict[:font] = params[:font] if params[:font]
      text_dict[:bg_color] = params[:bg_color] if params[:bg_color]
      text_dict[:font_color] = params[:font_color] if params[:font_color]
      text_dict[:font] = params[:font_name] if params[:font_name]

      new_str = Time.now.to_i.to_s
      new_name_png = new_str + ".png"
      to_image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
      text = "caption:#{params[:text]}"
      image =  Magick::Image.read( text ) do
        self.size = text_dict[:size]
        self.pointsize = text_dict[:pointsize]
        self.font = text_dict[:font]
        self.background_color = text_dict[:bg_color]
        self.gravity =  Magick::NorthGravity
        self.fill = text_dict[:font_color]
        #self.transparent_color = 'yellow'
        #self.font_weight = 100
        #self.font_family = "Arial"
        #self.font_style = Magick::NormalStyle
        
        #self.stroke_opacity = 0.5
        #self.letter_spacing = 3
        #self.word_spacing = 3
      end
      image[0].write(to_image_root)

      data=File.new(to_image_root, "rb").read
      send_data(data, :filename => new_name_png, :type => "image/png", :disposition => "inline")
  end

  def text2image
    require 'RMagick'
   
    text_dict = {
        :size => '200x',
        :pointsize => 50,
        :font => '',
        :bg_color => 'red',
        :font_color => 'blue'
    }

    text_dict[:bg_color] = params[:bg_color] if params[:bg_color]
    text_dict[:font_color] = params[:font_color] if params[:font_color]
    text_dict[:font] = params[:font] if params[:font]
    if text_dict[:font] == "simhei" or text_dict[:font] == "simsun"
      text_dict[:font] = "public/fonts/" +  text_dict[:font] + ".ttf"
    end 
    p text_dict   
 
    watermark = Magick::Image.new(200,50) do |i|
      i.background_color = text_dict[:bg_color]
    end

    watermark_text = Magick::Draw.new
    watermark_text.annotate(watermark, 0,0,0,0, params[:text]) do
      watermark_text.gravity = Magick::CenterGravity
      self.pointsize = 50
      #self.font = text_dict[:font]
      #self.font_family = "Arial"
      self.font = text_dict[:font]
      self.font_weight = Magick::BoldWeight
      self.stroke = "none"
      #self.stroke_opacity = 0.5
      #self.letter_spacing = 3
      #self.word_spacing = 3
      self.fill = text_dict[:font_color]
   end
   new_str = Time.now.to_i.to_s
   new_name_png = new_str + ".png"
   to_image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}" 
   watermark.write(to_image_root)
 
   data=File.new(to_image_root, "rb").read
   send_data(data, :filename => new_name_png, :type => "image/png", :disposition => "inline")
  end
 

  private
  
  def rand_str(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    str = ""
    1.upto(len) { |i| str << chars[rand(chars.size-1)] }
    return str
  end

  def dispose_items(items, uid)

    tmp_image_dir = "/var/tmp/tmp_image/#{uid}/"
    tmp_dir = "/var/tmp/#{uid}/"
    tmp_resize_dir = "/var/tmp/resize/#{uid}/"

    x_arr = items.collect{|i| i["x"].to_f }.to_a
    y_arr = items.collect{|i| i["y"].to_f }.to_a

    wx_arr = items.collect{|i| i["w"].to_f + i["x"].to_f }.to_a
    hy_arr = items.collect{|i| i["h"].to_f + i["y"].to_f }.to_a

    smallest_x = x_arr.min
    biggest_wx = wx_arr.max

    smallest_y = y_arr.min
    biggest_hy = hy_arr.max

    big_w = biggest_wx - smallest_x
    big_h = biggest_hy - smallest_y

    biggest = [big_h, big_w].max

    resize_l = 800 / biggest

    l_y = (800 - big_h * resize_l) / 2
    l_x = (800 - big_w * resize_l) / 2


    items.each_with_index do |i, index|
      if valid( i )
          image_root = get_img_path(i)

          unless i["mask_spec"].blank? and i['template_spec'].blank?
            spec = i["mask_spec"]

            spec_json = spec

            spec_arr = []
            unless spec_json.blank?
                  spec_json.each do |sj|
                    spec_arr << sj["x"].to_f
                    spec_arr << sj["y"].to_f
                  end
                  tspec = spec_arr.join(" ")
            else
                  tspec = "#{i['template_spec']['template_id']} #{i['template_spec']['x']} #{i['template_spec']['y']} #{i['template_spec']['scale']}"
            end

            matter = Matter.find_by_image_name( i["thing_id"] )
            mask_spec = MaskSpec.find_all_by_matter_id_and_mask_spec(matter.id, tspec).last
            i["spec_str"] = tspec

            unless mask_spec.blank?
              new_name_png = "#{mask_spec.mask_spec_image_name}.png"
              image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
            else
              #TODO
            end
          end
          
          i["ow"] = i["w"]
          i["oh"] = i["h"]
          i["ox"] = i["x"]
          i["oy"] = i["y"]

          i["x"] = (i["x"].to_f - smallest_x) * resize_l
          i["y"] = (i["y"].to_f - smallest_y) * resize_l
          i["w"] = i["w"].to_f * resize_l
          i["h"] = i["h"].to_f * resize_l


          unless i["transform"].blank?
           begin

            #图片旋转处理程序目录
            image_dispose_int = "/var/ImageDispose/imrotate2"

            image_root_rotate_dir = "#{tmp_dir}#{i["thing_id"]}#{index}"
            image_root_rotate_file = "#{tmp_dir}#{i["thing_id"]}#{index}.png"
            image_root_rotate_file_resize = "#{tmp_resize_dir}#{i["thing_id"]}#{index}.png"

            #缩放图片
            resize_image_program_dir = "/var/ImageDispose/image_resize"
            
            p "cd #{resize_image_program_dir} && ./image_resize #{image_root} #{i['w']} #{i['h']} #{image_root_rotate_file_resize}"
            `cd #{resize_image_program_dir} && ./image_resize #{image_root} #{i["w"]} #{i["h"]} #{image_root_rotate_file_resize}`

            #image_tmp = MiniMagick::Image.open(image_root, "png")
            #image_tmp.resize "#{i["w"]}x#{i["h"]}"
            #image_tmp.write image_root_rotate_file_resize
            transform_str = i["transform"].join(' ') 

            puts "cd #{image_dispose_int} && ./imrotate #{image_root_rotate_file_resize} #{transform_str} #{image_root_rotate_dir}"

            `cd #{image_dispose_int} && ./imrotate #{image_root_rotate_file_resize} #{transform_str} #{image_root_rotate_dir}`

            image_tmp_b = MiniMagick::Image.open(image_root_rotate_file)

            w = image_tmp_b[:width]
            h = image_tmp_b[:height]

            new_x = (i["w"] - w)/2
            new_y = (i["h"] - h)/2

            i["w"] = w
            i["h"] = h
            i["x"] = i["x"] + new_x
            i["y"] = i["y"] + new_y
           rescue=>e
            p e.to_s
           end
        end
      end
    end
    items
  end

  def items_sort_by_z(items)
    unless items.blank?
      1.upto(items.length-1) do |i|
        (items.length-i).times do |j|
          if items[j]["z"].to_i > items[j+1]["z"].to_i
            items[j],items[j+1] = items[j+1],items[j]
          end
        end
      end
    end
    items
  end

  def get_img_path(field)
    if field['type'] == 'image_url'  
      url = field['url']
      name = Digest::MD5.hexdigest( url )
      field['thing_id'] = name      

      image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{name}.png"
      if not FileTest::exist?(image_root) 
        p "wget #{url} -O #{image_root}"
        `wget #{url} -O #{image_root}`
      end
      image_root
    elsif field['type'] == 'image64'
      bi_image=Base64::decode64( field['image_dat'] )
      name = Digest::MD5.hexdigest( field['image_dat'].to_s )
      field['thing_id'] = name

      image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{name}.png"
      if not FileTest::exist?(image_root)
        File.open(image_root, "wb") { |f| f.write( bi_image ) }
        #`cd /var/ImageDispose/convert_png && ./process_png #{image_root} #{image_root}` 
      end
      p image_root
      image_root
    elsif field['type'] == 'text'
      key = field['text'] + field['text_des'].to_s
      p key
      name = Digest::MD5.hexdigest( key )
      image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{name}.png"
 
      field['thing_id'] = name 
      require 'RMagick'
      text_dict = {
        :text => field['text'],
        :size => field['text_des']['size'].to_i,
        :pointsize => field['text_des']['font_size'].to_i,
        :font => field['text_des']['font_name'].to_s,
        :bg_color => field['text_des']['bg_color'].to_s,
        :font_color => field['text_des']['font_color'].to_s,
        :font_alpha => field['text_des']['font_alpha'] 
      }
      
      if text_dict[:font] == "simhei" or text_dict[:font] == "simsun"
        text_dict[:font] = "public/fonts/" +  text_dict[:font] + ".ttf"
      end

      p text_dict

      if not FileTest::exist?(image_root)
        p 1
        watermark = Magick::Image.new(200, 50) do |i|
          i.background_color = text_dict[:bg_color]
        end
        p 2
        watermark_text = Magick::Draw.new
        watermark_text.annotate(watermark, 0,0,0,0, field[:text]) do
          watermark_text.gravity = Magick::CenterGravity
          self.pointsize = text_dict[:pointsize]
          self.font = "public/fonts/simhei.ttf"

          #self.font = text_dict[:font]
          #self.font_family = "Arial"
          #self.font_weight = Magick::BoldWeight
          self.stroke = "none"
          #self.stroke_opacity = text_dict[:font_alpha]
          self.fill = text_dict[:font_color]
          #self.fill_opacity = '0.3'
        end
        p 3
        watermark.write(image_root)
        `cd /var/ImageDispose/convert_png && ./process_png #{image_root} #{image_root}`    
      end
      image_root 
    else
      image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{field["thing_id"]}.png"
      if not FileTest::exist?(image_root)
         url = AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{field["thing_id"]}.png"
         p "wget #{url} -O #{image_root}"
         `wget #{url} -O #{image_root}`
      end

      image_root_1 = "/var/tmp/convert_png/tid/#{field["thing_id"]}.png"
      if field["bkgd"].to_i == 1 or ( not FileTest::exist?(image_root) )
        image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/size/orig/tid/#{field["thing_id"]}.jpg"
        if not FileTest::exist?(image_root)
           url = AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/size/orig/tid/#{field["thing_id"]}.jpg"
           `wget #{url} -O #{image_root}`
        end
        
        image_root_1 = "/var/tmp/convert_png/tid/#{field["thing_id"]}.jpg"
      end
      
      if not FileTest::exist?(image_root_1) or  File.size(image_root_1) < 100
        p "cd /var/ImageDispose/convert_image && ./convert_image #{image_root} #{image_root_1}"
        `cd /var/ImageDispose/convert_image && ./convert_image #{image_root} #{image_root_1}`
        #`cd /var/ImageDispose/convert_png && ./process_png #{image_root} #{image_root_1}`
        image_root = image_root_1
      end
      if FileTest::exist?(image_root_1)
        image_root = image_root_1
      end
      #p "user convert png=", image_root
      image_root
    end 
  end

  def get_mask_spec_image( new_name_png )
      image_root = "#{Photo::Sjb_root}/public/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
      unless FileTest::exist?(image_root)
        url = "http://qingchao1.qiniudn.com" + "/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
        `wget #{url} -O #{image_root}`
      end
      image_root
  end

end
