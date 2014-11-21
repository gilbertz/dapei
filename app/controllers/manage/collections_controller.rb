# encoding: utf-8
class Manage::CollectionsController < Manage::BaseController

  def cover_photo
    @collection = Collection.find params[:id]
    @skus = Sku.find params[:sku_ids].split(',')
    @collection.cover_photo(@skus)
    respond_to do |format|
      format.js
    end
  end


   def update
    dapei = Collection.find_by_url params[:id]
    if params[:meta_tags]
      dapei.meta_tag_id = params[:meta_tags]
      dapei.mtag_list = ""
      if params[:meta_tags].to_i >0
        dapei.mtag_list.add(MetaTag.find(params[:meta_tags]).tag)
        dapei.tag_list << dapei.mtag_list
      end
      dapei.save
    end
    dapei_info = dapei.dapei_info
    pre_category_id = dapei.category_id
    if params[:tags]
      dapei_info.tag_list.add(params[:tags])
    end

    @once = false
    @once = true if params[:once] == "1"

    unless @once
      current_level = params[:collection][:level].to_i
      $redis.set('level_' + dapei.url, params[:collection][:level])
      params[:collection].delete :level
      if dapei.category_id == 1001
        $redis.lpush('dp_to_be_shown', dapei.url)
      else
        $redis.lpush('col_to_be_shown', dapei.url)
      end
    end

    prev_level = dapei.level.to_i
    if dapei.update_attributes params[:collection] and dapei_info
      dapei_info.dapei_tags_id = params[:dapei_tags_id]
      dapei_info.update_attributes params[:dapei_info]
      current_category_id = dapei.category_id
      if pre_category_id == 1001 and current_category_id == 1000
        dapei.dapei2collection
      end

      if @once
        current_level = dapei.level.to_i

        if prev_level == 0 and current_level >= 2
          dapei.rand_like
          PushNotification.push_review_dapei(dapei.get_user.id, dapei.url)
        end
        if prev_level < 5 and current_level >= 5
          dapei.rand_like
          PushNotification.push_star_dapei(dapei.get_user.id, dapei.url)
        end
      end

      if dapei.category_id == 1001 or dapei.category_id == 1000
        if params[:start_date]
          dapei.dapei_info.start_date = params[:start_date]
        end
        if params[:end_date]
          dapei.dapei_info.end_date = params[:end_date]
        end

        if params[:start_date_hour]
          dapei.dapei_info.start_date_hour = params[:start_date_hour]
        end

        if params[:dapei_tags_id]
          dapei.dapei_info.dapei_tags_id = params[:dapei_tags_id].to_i
        end
      end
      dapei.dapei_info.save
    end
    if dapei.level && dapei.level >= 2
      FlashBuy::Api.add_coin(dapei, 'push_homepage')
    end
    redirect_to :back
    #redirect_to [:manage,:dapeis]
  end
end
