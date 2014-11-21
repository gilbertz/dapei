class Shangjieba.Views.ShopShow extends Backbone.View
  initialize: ->
    _.bindAll(this, "render");
    @model.bind("change", @render)
  
  template: JST['shops/show']

  render: ->
    $(@el).html(@template(shop: @model))
    new_comment = new Shangjieba.Models.Comment(commentable : @model)
    new_comment_view = new Shangjieba.Views.CommentNew(model : new_comment)
    this.$('#new_comment').html(new_comment_view.render().el)
    new_comment_view.delegateEvents()

    this
