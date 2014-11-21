module ApiHelpers
  def body_parasm
    params_ =  request.body.read.gsub("\x00","{")
    params_json = JSON.parse params_
  end
end
require 'acme/V4/api_brand'
require 'acme/V4/api_home'
require 'acme/V4/api_tag'
require 'acme/V4/api_selfie'

class SjbApi < Grape::API
  helpers ApiHelpers
  # version 'v1', using: :header, vendor: 'sjb'
  prefix 'api'
  # content_type :json ,"application/json"
  format :json
  # use Rack::PostBodyContentTypeParser
  formatter :json, Grape::Formatter::Jbuilder
  # 上街吧 app v4.0.4 版本
  mount Acme::V4::ApiBrand
  mount Acme::V4::ApiSelfie
  mount Acme::V4::ApiTag
  mount Acme::V4::ApiHome
end