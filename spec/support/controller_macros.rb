# -*- encoding : utf-8 -*-
module ControllerMacros
  def stub_env(new_env, &block)
      original_env = Rails.env
      Rails.instance_variable_set("@_env", ActiveSupport::StringInquirer.new(new_env))
      block.call
  ensure
      Rails.instance_variable_set("@_env", ActiveSupport::StringInquirer.new(original_env))
  end

end
