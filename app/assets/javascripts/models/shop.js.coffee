class Shangjieba.Models.Shop extends Backbone.Model
  initialize: () ->
    @type = "Shop" #commentable
    @bind 'change', =>
      @comments = @nestCollection(this, 'comments', new Shangjieba.Collections.Comments(this.get('comments')))
      @items = @nestCollection(this, 'items', new Shangjieba.Collections.Comments(this.get('items')))
      @discounts = @nestCollection(this, 'discounts', new Shangjieba.Collections.Comments(this.get('discounts')))
      @photos = @nestCollection(this, 'photos', new Shangjieba.Collections.Photos(this.get('photos')))

  sync: (method, model, options) ->
    options = options || {}
    options.url =
      if method.toLowerCase() == 'create'
        "shops"
      else
        "shops/" + model.get('url')
    Backbone.sync(method, model, options)
