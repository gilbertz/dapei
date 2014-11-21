# -*- encoding : utf-8 -*-
class StatController < ApplicationController
   def report
     if params[:type] and params[:id]
       key = "#{params[:type]}_#{params[:id]}"
       @count = $redis.incr(key)
     end
     render :nothing => true
   end

end
