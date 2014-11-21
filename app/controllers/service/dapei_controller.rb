# -*- encoding : utf-8 -*-
class Service::DapeiController < Service::BaseController

  require 'open-uri'

  Image_dispose_color = "/var/ImageDispose/extract_color"

  Image_tmp_dir = "/var/tmp/sjb_image"

  Image_dispose_cut = "/var/ImageDispose/template_cut"

  Image_cut_dir = "#{Rails.root}/public/uploads/cut"


  def template_cut
    img_url = params[:img_url]       
    template_img = "/var/ImageDispose/template_cut/#{params[:tid]}.png"
    result_img = "#{Image_dispose_cut}/#{Time.now.to_i}.png"
    
    tmp_image_file = Image_tmp_dir + "#{Time.now.to_i}.png"
    File.open(tmp_image_file,'wb'){ |f| f.write open(img_url).read }   
 
    x = params[:x]
    y = params[:y]
    scale = "1.0"
    scale = params[:scale] if params[:scale]
   
    p "cd #{Image_dispose_cut} && ./template_cut #{tmp_image_file} #{template_img} #{result_img} #{x} #{y} #{scale}"
    `cd #{Image_dispose_cut} && ./template_cut #{tmp_image_file} #{template_img} #{result_img} #{x} #{y} #{scale}`

    cut_image_root = "#{result_img}" 
    data=File.new(cut_image_root, "rb").read
    send_data(data, :filename => result_img, :type => "image/png", :disposition => "inline")
  end

  def cut_templates
    templates = []
    (1..4).each do |i|
      templates << {id:i, img_url: "http://qingchao1.qiniudn.com/uploads/cut/#{i}.png"}
    end
    render :json => { templates: templates }
  end


  # 对图片进行取色
  # params  image_url  图片的远程路径
  # return  {colors: "color1 color2 color3"}
  def get_color
    colors = get_color_by_url(params[:image_url])
    render :json => { colors: colors }
  end

  private
  def get_color_by_url(image_url)
    unless image_url.blank?
      unless Dir.exist?(Image_tmp_dir)
        FileUtils.mkdir_p(Image_tmp_dir)
        `chmod -R 1777 #{Image_tmp_dir}`
        puts "--------------- create dir #{Image_tmp_dir}---------------"
      end

      tmp_image_file = Image_tmp_dir + File.basename(image_url)

      File.open(tmp_image_file,'wb'){ |f| f.write open(image_url).read }

      puts "cd #{Image_dispose_color} && ./extract_color color1.txt #{tmp_image_file}"

      colors = `cd #{Image_dispose_color} && ./extract_color color1.txt #{tmp_image_file}`
      colors = colors.chomp
      `rm #{tmp_image_file}`
      colors
    else
      raise "image url is blank"
    end
  end

end
