namespace :backup do

  task :img => :environment do
      count = Photo.maximum('id').to_i
      for id in (1..count+1) do
          p id if id%100 == 0
          p = Photo.find_by_id( id )
          next unless p
          p p.target_type
          if p.target_type != "Item"
              file_path = "/var/www/shangjieba/public/uploads/images/#{p.remote_photo_name}"
              backup_path = "/var/www/shangjieba_dat/uploads/images_1/#{p.remote_photo_name}"
              next unless FileTest::exist?( file_path )
              next if FileTest::exist?( backup_path )

              `cp #{file_path} #{backup_path}`
              p file_path
          end
      end
  end

end
