# -*- encoding : utf-8 -*-
class M::WelcomeController < M::BaseController
  def index

    render :layout => "m/layouts/base"
  end
end
