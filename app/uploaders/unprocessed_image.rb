# -*- encoding : utf-8 -*-
#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# encoding: utf-8

class UnprocessedImage < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/images"
  end

  #def extension_white_list
  #  %w(jpg jpeg png gif)
  #end

  def filename
    if @filename
      ext_name = File.extname(@filename)
      unless %w(jpg jpeg png gif).include?(ext_name)
        model.random_string + ".jpg"
      else
        model.random_string + ext_name
      end
    end
  end

  process :resize_to_limit => [800, 800]
  
  #version :thumb_smal
  #version :thumb_medium
  #version :scaled_medium
  #version :wide_medium
  #version :wide_half
  #version :wide_large
  
  #version :scaled_medium do
  #  process :pre 
  #  process :resize_to_limit => [220,nil]
  #end

  #version :scaled_large do
  #  process :pre
  #  process :resize_to_limit => [350,nil]
  #end

  #version :normal_small do
  #  process :pre
  #  process :resize_to_fill => [150,200]
  #end

  #version :normal_medium do
  #  process :pre
  #  process :resize_to_fill => [300,400]
  #end

  
  #version :wide_small do
  #  process :pre
  #  process :resize_to_fill => [312, 150]
  #end

  #version :wide_medium do
  #  process :pre
  #  process :resize_to_fill => [484,180]
  #end

  #version :wide_half do
  #  process :pre
  #  process :resize_to_fill => [242,180]
  #end

  #version :wide_large do
  #  process :pre
  #  process :resize_to_fill => [645,240]
  #end

  #version :wide_banner do
  #  process :pre
  #  process :resize_to_fill => [710,270]
  #end


  version :scaled_full do
    process :pre
    process :get_version_dimensions
    process :resize_to_fit => [600,nil]
    #process :add_date
    #process :watermark 
  end

  def watermark
    manipulate! do |img|
      logo = MiniMagick::Image.open("#{Rails.root}/app/assets/images/watermark.png")
      img.composite(logo) do |c|
        c.gravity "SouthEast"
      end
    end
  end   

  def add_date
    t = Time.new
    date = t.strftime("%Y-%m-%d %H:%M:%S")
    publish = "#{date}"
    `convert -font Arial -fill white -pointsize 20   -draw "gravity SouthWest fill black text 0,12 '#{publish}'" #{file.path} #{file.path}`
  end

 
  def pre
    `jhead -autorot #{file.path}`
     #`export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib && enhance #{file.path} #{file.path}`
  end


  def get_version_dimensions
    model.width, model.height = `identify -format "%wx%h " #{file.path}`.split(/x/)
  end
end
