namespace :color do
  task :create_color => :environment do
    File.open("#{Rails.root}/color.txt") do |file|
      file.each do |line|
        new_arr = line.split(" ")

        color = Color.new
        color.color_name = new_arr[0].strip
        color.color_r = new_arr[1].strip
        color.color_g = new_arr[2].strip
        color.color_b = new_arr[3].strip
        color.color_rgb = "#{color.color_r} #{color.color_g} #{color.color_b}"
        color.save

        puts color
        puts "-----------save----------------"
      end
    end
  end



  task :convert_color => :environment do
    colors = Color.all
    colors.each do |color|

      if color.color_r.to_s(16).length < 2
        r = "0#{color.color_r.to_s(16)}"
      else
        r = color.color_r.to_s(16)
      end

      if color.color_g.to_s(16).length < 2
        g = "0#{color.color_g.to_s(16)}"
      else
        g = color.color_g.to_s(16)
      end

      if color.color_b.to_s(16).length < 2
        b = "0#{color.color_b.to_s(16)}"
      else
        b = color.color_b.to_s(16)
      end


      c16 = "#{r}#{g}#{b}"
      color.color_16 = c16
      puts "--------#{c16}----------"
      color.save
    end
  end
end