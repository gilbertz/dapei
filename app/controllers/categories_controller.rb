# -*- encoding : utf-8 -*-
class CategoriesController < ApplicationController
  def index
    @candidates = Category.all
    @categories=[]
    @candidates.each do |c|
      if c.abb!="all" and c.abb!="dapei" and c.abb!="yifu"
        @categories<<c
      end
    end
    respond_to do |format|
      format.html # new.html.haml
      format.json {render_for_api :public,  :json => @categories, :meta=>{:result=>"0"}}
    end
  end

  
  def group
    @rule_categories = Category.where("id > 10 and thing_img_id is not null").where(:is_active => true)
    @rule_categories += Category.where("id > 3 and id < 10").where(:is_active => true)
    @rule_categories << Category.find_by_id(2011)
    @rule_categories = @rule_categories.sort_by{ |cat| -1*(cat.weight.to_i) } 

    respond_to do |format|
      format.html # new.html.haml
      format.json {render_for_api :priv,  :json => @rule_categories, :meta=>{:result=>"0"}}
    end
  end
   
  def for_dapei
    @rule_categories = []
    @rule_categories = Category.find([11,12,13])
    #@rule_categories << Category.find(7)

    respond_to do |format|
      format.html # new.html.haml
      format.json {render_for_api :dp,  :json => @rule_categories, :meta=>{:result=>"0"}}
    end
  end


end
