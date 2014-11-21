class Shangjieba.Models.Photo extends Backbone.Model
  initialize: () ->
    @type = "Photo" #commentable
    @bind 'change', =>
      @photos = @nestCollection(this, 'photos', new Shangjieba.Collections.Photos(this.get('photos')))

  sync: (method, model, options) ->
    options = options || {}
    prefix = "shops/" + model.get('shop_url') + "/photos"
    options.url =
      if method.toLowerCase() == 'create'
        prefix
      else
        prefix + "/" + model.get('url')
    Backbone.sync(method, model, options)
