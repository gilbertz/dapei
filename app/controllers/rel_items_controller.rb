# -*- encoding : utf-8 -*-
class RelItemsController < ApplicationController
    before_filter :authenticate_user!
    
    def destroy
       rel = RelItems.find( params[:id] )
       rel.destory
       respond_to do |format|
         format.html { redirect_to :back }
       end
    end     

end
