namespace :color_go do

  task :go => :environment do
    Matter.find_each do |m|

      unless m.color_one_id.blank?
        if m.color_one_id > 651
          m.color_one_id = m.color_one_id.to_i - 651
        end
      end

      unless m.color_two_id.blank?
        if m.color_two_id > 651
          m.color_two_id = m.color_two_id.to_i - 651
        end
      end

      unless m.color_three_id.blank?
        if m.color_three_id > 651
          m.color_three_id = m.color_three_id.to_i - 651
        end
      end

      m.save

      puts m.inspect
      puts "-------------------------------------------------------"
    end
  end

end