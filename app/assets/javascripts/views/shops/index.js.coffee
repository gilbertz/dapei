class Shangjieba.Views.ShopsIndex extends Backbone.View
  template: JST['shops/index']
  render: ->
    $(@el).html(@template(shops: @collection))
    this