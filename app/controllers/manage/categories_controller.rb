# -*- encoding : utf-8 -*-
class Manage::CategoriesController < Manage::BaseController
  before_filter :set_param_side

  before_filter :get_categories_for_select, :only => [:new, :edit]

  def index

    unless params[:sub].blank?
      ids = Category.where(:parent_id => 1).map(&:id)
      @q = Category.where(:parent_id => ids).includes(:parent).ransack params[:q]
    else

      unless params[:pid].blank?
        @q = Category.where(:parent_id => params[:pid]).includes(:parent).ransack params[:q]
      else
        @q = Category.includes(:parent).ransack params[:q]
      end

    end

    @categories = @q.result.order('id desc').page(params[:page]).per(18)
  end

  def for_select
    @categories = Category.where(:is_active => true).select([:name,:id]).page(params[:page]).per(156)
    render partial: 'for_select'
  end

  def new
    @category = Category.new
    render partial: 'form'
  end

  def create
    @category = Category.new(params[:category])

    unless params[:thumb].blank?
      tmp_dir = "#{Rails.root}/public/uploads/cgi/img-thing/size/s/tid/"
      file = params[:thumb]

      thing_id = "#{Time.now.to_i}#{rand(100)}"

      image_name = file.original_filename.split(".").last

      new_image = "#{thing_id}.#{image_name}"


      File.open("#{tmp_dir}#{new_image}", "wb") do |f|
        f.write(file.read)
      end

      @category.image_thing = thing_id.to_i
    end

    @category.save
    redirect_to [:manage, :categories]
  end

  def edit
    @category = Category.find params[:id]
    render partial: 'form'
  end

  def update
    category = Category.find params[:id]

    category.update_attributes params[:category]

    unless params[:thumb].blank?
      tmp_dir = "#{Rails.root}/public/uploads/cgi/img-thing/size/s/tid/"
      file = params[:thumb]

      thing_id = "#{Time.now.to_i}#{rand(100)}"

      image_name = file.original_filename.split(".").last

      new_image = "#{thing_id}.#{image_name}"

      File.open("#{tmp_dir}#{new_image}", "wb") do |f|
        f.write(file.read)
      end

      category.image_thing = thing_id.to_i
      category.save
    end

    redirect_to [:manage, :categories]
  end

  def destroy
    category = Category.find params[:id]
    render nothing: true
  end

  def set_photo
    category = Category.find_by_id(params[:category_id])
    matter   = Matter.find_by_id(params[:matter_id])

    category.image_thing = matter.image_name
    category.save
    render :text => "~~~!!!success~~~~"
  end

  def set_app_photo
    c = Category.find(params[:category_id])

    f = params[:file]

    image_type = f.original_filename.split(".").last

    file_path = "/uploads/categories/#{c.id}-#{Time.now.to_i}.#{image_type}"

    local_path = "#{Rails.root}/public" + file_path

    tmp_image_dir = "#{Rails.root}/public/uploads/categories/"
    unless Dir.exist?(tmp_image_dir)
      FileUtils.mkdir_p(tmp_image_dir)
      puts "--------------- create dir #{tmp_image_dir}---------------"
    end

    File.open(local_path, 'wb') do |file|
      file.write(f.read)
    end

    c.app_icon_image = AppConfig[:remote_image_domain] + file_path
    c.save

    render :json => {:image_url => AppConfig[:remote_image_domain] + file_path }
  end

  def ajax_select_change
    unless params[:pid].blank?
      @categories = Category.where(:parent_id => params[:pid]).collect {|c| [c.name,c.id] }
    else
      @categories = Category.all.collect {|c| [c.name,c.id] }
    end

    @categories = [["选择分类", 0]] + @categories

    render :partial => "ajax_select_change"
  end


  def feature
    @main_colors = MainColor.all

    render :layout => false
  end

  def feature_create
    unless params[:feature].blank?
      params[:feature].each do |f|
        app_category_feature_image = AppCategoryFeatureImage.new(f)
        app_category_feature_image.category_id = params[:id]
        app_category_feature_image.save
      end
    end

    redirect_to :manage_categories_path
  end

  private
  def set_param_side
    @param_side = 'manage/matters/sidebar'
  end

  def get_categories_for_select
    @categories_for_select = Category.select([:name,:id]).collect do|rc|
      [rc.name, rc.id]
    end
  end
end
