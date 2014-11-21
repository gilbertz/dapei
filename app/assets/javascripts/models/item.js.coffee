class Shangjieba.Models.Item extends Backbone.Model
  initialize: () ->
    @type = "Item" #commentable
    @bind 'change', =>
      @comments = @nestCollection(this, 'comments', new Shangjieba.Collections.Comments(this.get('comments')))

  sync: (method, model, options) ->
    options = options || {}
    prefix = "shops/" + model.get('shop_url') + "/items"
    options.url =
      if method.toLowerCase() == 'create'
        prefix
      else
        prefix + "/" + model.get('url')
    Backbone.sync(method, model, options)
