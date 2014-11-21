# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::PhotosController < Manage::BaseController

  def destroy
    photo = Photo.find params[:id]
    photo.destroy
    render nothing: true
  end
end
