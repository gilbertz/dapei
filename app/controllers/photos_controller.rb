# -*- encoding : utf-8 -*-
#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PhotosController < ApplicationController
  before_filter :authenticate_user!, :except => :show
  
  respond_to :html, :json
  
  def create
    #print "No we are here@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    rescuing_photo_errors do
      #print "No we are herei2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      if remotipart_submitted?
        @photo = current_user.build_post(:photo, params[:photo])
        if @photo.save
          respond_to do |format|
            format.json { render :json => {"success" => true, "data" => @photo.as_api_response(:backbone)} }
          end
        else
          respond_with @photo, :location => photos_path, :error => message
        end
      else
        #print "No we are herei3@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        legacy_create
      end
    end
  end
  
  def make_profile_photo
    user_id = current_user.id
    @photo = Photo.where(:id => params[:photo_id], :user_id => user_id).first
    
    if @photo
      profile_hash = {:image_url        => @photo.url(:thumb_large),
                      :image_url_medium => @photo.url(:thumb_medium),
                      :image_url_small  => @photo.url(:thumb_small)}
      
      if current_user.update_profile(profile_hash)
        respond_to do |format|
          format.js{ render :json => { :photo_id  => @photo.id,
                                       :image_url => @photo.url(:thumb_large),
                                       :image_url_medium => @photo.url(:thumb_medium),
                                       :image_url_small  => @photo.url(:thumb_small),
                                       :author_id => author_id},
                            :status => 201}
        end
      else
        render :nothing => true, :status => 422
      end
    else
      render :nothing => true, :status => 422
    end
  end
  
  def destroy
    #photo = current_user.photos.where(:id => params[:id]).first
    photo=Photo.find(params[:id]) 
    if photo
      #current_user.retract(photo)
      photo.destroy
      respond_to do |format|
        format.json{ render :nothing => true, :status => 204 }
        format.html do
          flash[:notice] = I18n.t 'photos.destroy.notice'
          #if StatusMessage.find_by_guid(photo.status_message_guid)
          #  respond_with photo, :location => post_path(photo.status_message)
          #else
          #respond_with photo, :location => person_photos_path(current_user)
          #end
        end
      end
    else
      render :nothing=>true
      #respond_with photo, :location => :back
    end
  end
  
  def edit
    if @photo = current_user.photos.where(:id => params[:id]).first
      respond_with @photo
    else
      redirect_to person_photos_path(current_user.person)
    end
  end
  
  def update
    photo = current_user.photos.where(:id => params[:id]).first
    if photo
      if current_user.update_post( photo, params[:photo] )
        flash.now[:notice] = I18n.t 'photos.update.notice'
        respond_to do |format|
          format.js{ render :json => photo, :status => 200 }
        end
      else
        flash.now[:error] = I18n.t 'photos.update.error'
        respond_to do |format|
          format.html{ redirect_to [:edit, photo] }
          format.js{ render :status => 403 }
        end
      end
    else
      redirect_to person_photos_path(current_user.person)
    end
  end
  
  def parse_raw_url    
    parse_pic()
  end
  
  def get_pic
    parse_pic
    respond_to do |format|
      format.json { render :json => {"success" => true, "data" => @imgs.to_json } }
    end
  end
  
  
  private
  
  def parse_pic()
    @imgs = []
    if (params[:url])      
      if params[:url].downcase  =~/\.(jpg|jpeg|png|gif|tiff)/
         @imgs << params[:url]
         return
      end       
      doc = Hpricot(open(params[:url]) )
      #print doc
      img_hash=Hash.new
      doc.search("body img").each do |node|
        if(node[:src] =~/^https?:/)
          f=open(node[:src])
          if f.read.length > 10000 
            img_hash[node[:src]]=f.read.length  
            print node[:src], '->', f.read.length
            #@imgs.push(node[:src])
          end
        end
      end
      
      img_hash.sort{|a,b| a[1]<=>b[1]}.each do |elem|        
        @imgs << elem[0].sub(/\?(.*)$/, '')
      end
      @imgs.reverse
      if(@imgs.count>4)
        @imgs=@imgs[0,4]
      end
      print '!!!', @imgs
    end    
  end
  
  def file_handler(params)
    # For XHR file uploads, request.params[:qqfile] will be the path to the temporary file
    # For regular form uploads (such as those made by Opera), request.params[:qqfile] will be an UploadedFile which can be returned unaltered.
    if not request.params[:qqfile].is_a?(String)
      params[:qqfile]
    else
      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
      #file_name = SecureRandom.hex(10)
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      # create tempora##l file
      begin
        file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
        file.print request.raw_post.force_encoding('BINARY')
         
        #filename2="test_imgddd2.jpg20130219-32615-rqcfnt"
        #file2=File.new(filename2)
        #file2.binmode
        #content=File.read(file2)
        #file.print content.force_encoding('BINARY')
      rescue RuntimeError => e
        raise e unless e.message.include?('cannot generate tempfile')
        file = Tempfile.new(file_name) # Ruby 1.8 compatibility
        file.binmode
        file.print request.raw_post
      end   
     
      # put data into this file from raw post request
      
      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}
      file
    end
  end
  
  def legacy_create
    #if params[:photo][:aspect_ids] == "all"
    #  params[:photo][:aspect_ids] = current_user.aspects.collect { |x| x.id }
    #elsif params[:photo][:aspect_ids].is_a?(Hash)
    #  params[:photo][:aspect_ids] = params[:photo][:aspect_ids].values
    #end

    if not params[:qqfile]
       params[:qqfile] = params[:name]
    end
    if not params[:photo]
       params[:photo] = {}
       params[:photo][:user_file]  = params[:file]
    else  
       params[:photo][:user_file] = file_handler(params)
    end
    #print params[:photo]

    @photo = current_user.build_post(:photo, params[:photo])
    
    if @photo.save
      #aspects = current_user.aspects_from_ids(params[:photo][:aspect_ids])
      
      #unless @photo.pending
      #  current_user.add_to_streams(@photo, aspects)
      #  current_user.dispatch_post(@photo, :to => params[:photo][:aspect_ids])
      #end

      if params[:photo][:set_profile_photo]
        profile_params = {:image_url => @photo.url(:thumb_large),
                          :image_url_medium => @photo.url(:thumb_medium),
                          :image_url_small => @photo.url(:thumb_small)}
        current_user.update_profile(profile_params)
      end
      
      respond_to do |format|
        format.json{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
        format.html{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
      end
    else
      respond_with @photo, :location => photos_path, :error => message
    end
  end
  
  def rescuing_photo_errors
    begin
      yield
    rescue TypeError
      message = I18n.t 'photos.create.type_error'
      respond_with @photo, :location => photos_path, :error => message
      
    rescue CarrierWave::IntegrityError
      message = I18n.t 'photos.create.integrity_error'
      respond_with @photo, :location => photos_path, :error => message
      
    rescue RuntimeError => e
      message = I18n.t 'photos.create.runtime_error'
      respond_with @photo, :location => photos_path, :error => message
      raise e
    end
  end
end
