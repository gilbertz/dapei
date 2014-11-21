class Shangjieba.Models.Discount extends Backbone.Model
  sync: (method, model, options) ->
    options = options || {}
    prefix = "shops/" + model.get('shop_url') + "/discounts"
    options.url =
      if method.toLowerCase() == 'create'
        prefix
      else
        prefix + "/" + model.get('url')
    Backbone.sync(method, model, options)
