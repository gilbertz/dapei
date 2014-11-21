namespace :image_test do
  task :go => :environment do

    file_one = "#{Rails.root}/public/cgi/img-thing/mask/1/size/orig/tid/1379078200647.png"


    image = MiniMagick::Image.open(file_one, "png")

    image.resize "1900x1900"

    image.crop "200x200+10+10"

    image.write "/home/shuwei/my_output_file.png"
  end
end