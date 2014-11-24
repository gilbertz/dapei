# -*- encoding : utf-8 -*-
class Manage::SynonymsController < Manage::BaseController

  before_filter :set_param_side

  def index
    @categories = Category.includes(:synonyms).get_all_active_sub_categories
  end

  def create
    @synonym = Synonym.new
    @synonym.category_id = params[:category_id]
    @synonym.content = params[:content].strip
    @synonym.save
    redirect_to :back
  end

  def destroy
    @synonym = Synonym.find(params[:id])
    @synonym.destroy
    redirect_to :back
  end

  private
  def set_param_side
    @param_side = 'manage/categories/sidebar'
  end

end
