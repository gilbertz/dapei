class Shangjieba.Models.Comment extends Backbone.Model
  initialize: ->
    @commentable = @get('commentable')
  url: ->
    root =
      if @commentable.type == "Shop"
        "shops/"
      else if @commentable.type == "Item"
        "shops/" + @commentable.get('shop_url') + "/items/"
    root + @commentable.get("url") + "/comments"
