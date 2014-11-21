# -*- encoding : utf-8 -*-
class Manage::PropertiesController < Manage::BaseController

  def index
    @properties = Property.all
  end

  def new
    @property = Property.new
  end

  def create
    @property = Property.new(params[:property])
    @property.save
    redirect_to manage_properties_path
  end

end
