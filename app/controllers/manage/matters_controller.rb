# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::MattersController < Manage::BaseController

  def index
    params[:side] = 'manage/dapeis/sidebar'
    @matters = Matter
    if params[:sku_id]
      @matters =Matter.where(:sku_id => params[:sku_id])
    elsif params[:brand_id]
      @matters = Matter.joins("left join skus on skus.id = matters.sku_id").where("skus.brand_id = #{params[:brand_id]}")
    elsif params[:sub_category_id]
      @matters = Matter.joins("left join skus on skus.id = matters.sku_id").where("skus.sub_category_id = #{params[:sub_category_id]}")
    elsif params[:category_id]
      @matters = Matter.where("category_id = #{params[:category_id]}")
    elsif params[:user_id]
      @matters = Matter.where(:user_id => params[:user_id])
    end

    @q = @matters.includes([:category]).ransack params[:q]
    @matters = @q.result.order('id desc').page(params[:page]).per(20)
  end

  def new
    # 1140 分类下的为 素材分类
    @categories = Category.where(:parent_id => 1140).collect{|c| [c.name, c.id] }
    @matter_tags = ::MatterTag.all 
    @matter = Matter.new
  end

  def recommended
    return render(json: {msg: 'pid不能为空！'})  if params[:pid].blank?
    return render(json: {msg: 'sid不能为空！'})  if params[:sid].blank?
    photo = Photo.find_by_id(params[:pid])
    if Matter.find_by_sjb_photo_id(params[:pid])
      photo.is_send = 1
      photo.save
      render json: { result: "Warn!~~~已经存在~~~"}
    else
      @matter = Matter.new
      @matter.source_type = 1
      @matter.sjb_photo_id = params[:pid]
      @matter.sku_id = params[:sid]
      @matter.level = 5
      sku = Sku.find(params[:sid])
      sku_category_id = sku.category_id
      category_id = sku_category_id
      @matter.category_id = category_id

      if @matter.save
        photo.is_send = 1
        photo.save
        render json: { result: "OK！~~~成功~~~" }
      else
        render json: { result: "Warn!~~~失败~~~" }
      end
    end
  end

  def create


      local_path = "#{Rails.root}/public/uploads/matters/"

      dir_path = local_path
      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

      unless params[:matter_image].blank?

        params[:matter_image].each do |mi|

          file_type  = mi.original_filename.split(".").last
          new_str    = Time.now.to_i.to_s + ((100..999).to_a.shuffle[0].to_s)
          if file_type == "jpg" or file_type == "png"
            local_file_name = new_str + "." + file_type
            local_file = local_path + local_file_name

            File.open(local_file, "wb") { |f| f.write( mi.read ) }

            m = Matter.new
            #上传
            m.source_type = 4
            m.is_cut = 0
            # m.category_id = 100

            m.category_id = params[:matter][:category_id]

            unless params[:matter_tags].blank?
              m.tags = params[:matter_tags].join(" ")
            end

            m.local_photo_path = local_path
            m.local_photo_name = local_file_name
            m.image_name = new_str
            m.save
          end

        end

      end

      redirect_to [:new,:manage,:matter]
  end

  def brands
    @is_link = params[:is_link].to_i
    @brands = Brand.select([:id,:name]).where("level >= ?", 3).order("last_updated desc, priority desc, url asc")
    render layout: false
  end

  def tags
    @tags = Tag.select([:id,:name]).order{weight.desc}
    render layout: false
  end

  def compose_conditional
    cond = "1=1"
    params[:catid] && !params[:catid].strip.empty? && params[:catid]!="0" && cond += " and skus.category_id = #{params[:catid]}"
    params[:brandid] && !params[:brandid].strip.empty? && params[:brandid]!="0" && cond += " and skus.brand_id = #{params[:brandid]}"
    params[:tagid] && !params[:tagid].strip.empty? && cond += " and taggings.tag_id = #{params[:tagid]}"
    params[:price_start] && !params[:price_start].strip.empty? && cond += " and skus.price >= #{params[:price_start]}"
    params[:price_end] && !params[:price_end].strip.empty? && cond += " and skus.price <= #{params[:price_end]}"
    cond
  end

  def text_values
    if (params[:catid]) && (!params[:catid].strip.empty?) && (params[:catid]!="0")
      @catid_text_value = @c_selects[params[:catid]]
    end

    if (params[:brandid]) && (!params[:brandid].strip.empty?) && (params[:brandid]!="0")
      @brandid_text_value = Brand.find(params[:brandid]).name
    end

    if (params[:tagid]) && (!params[:tagid].strip.empty?)
      @tagid_text_value = Tag.find(params[:tagid]).name
    end
  end

  def recommends
  end

  def edit
    @categories = Category.where("id > 3 and thing_img_id is not null").collect{|c| [c.name, c.id] }
    @categories += Category.where(:parent_id => 1140).collect{|c| [c.name, c.id] }
    
    @matter_tags = ::MatterTag.all 
    @matter = Matter.find params[:id]
  end

  def update
    @matter = Matter.find params[:id]
    params[:matter_tags] && params[:matter][:tags] = params[:matter_tags].join(" ")
    @matter.update_attributes params[:matter]
    redirect_to [:manage,:matters]
  end

  def destroy
    @matter = Matter.find params[:id]
    @matter.destroy
    render nothing: true
  end

  
  def koutu
     @matter = Matter.find params[:id]
     unless params[:yt]
       @matter.dump if @matter
     else
       @matter.dump(false) if @matter
     end
     render nothing: true     
  end

end
