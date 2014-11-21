# -*- encoding : utf-8 -*-
class Manage::ShipmentsController < Manage::BaseController

  #具体编码查询 快递100 API

  def update
    @shipment = Shipment.find(params[:id])
    @shipment.shipname = params[:shipment_type]
    @shipment.number = params[:number]

    unless params[:number].blank?
      @shipment.state = 1
    end

    @shipment.save

    redirect_to :back
  end


end
