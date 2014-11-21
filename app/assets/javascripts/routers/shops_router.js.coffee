class Shangjieba.Routers.Shops extends Backbone.Router
  initialize: () ->
  routes :
    "" : "index"
    "new" : "new"
    "show/:url" : "show"
    "edit/:url" : "edit"
    "shops/:shop_url/items/new" : "new_item"
    "shops/:shop_url/items/:url" : "show_item"
    "shops/:shop_url/discounts/new" : "new_discount"
    "shops/:shop_url/discounts/:url" : "show_discount"

  index : ->
    shops = new Shangjieba.Collections.Shops()
    shops.fetch(
      success : () ->
        view = new Shangjieba.Views.ShopsIndex({collection:shops})
        $('#data').html(view.render().el)
        map_view = new Shangjieba.Views.ShopsMap({colletion:shops})
        map_view.render()
        )

  new : () ->
    shop = new Shangjieba.Models.Shop()
    view = new Shangjieba.Views.ShopNew({model:shop})
    $('#data').html(view.render().el)

  show : (url) ->
    shop = new Shangjieba.Models.Shop(url : url)
    shop.fetch(
      success : () ->
        view = new Shangjieba.Views.ShopShow({model:shop})
        $('#data').html(view.render().el)
        map_view = new Shangjieba.Views.MapShow({model:shop})
        map_view.render()
        )

  edit : (url) ->
    shop = new Shangjieba.Models.Shop(url : url)
    shop.fetch(
      success : () ->
        view = new Shangjieba.Views.ShopEdit({model:shop})
        $('#data').html(view.render().el)
      )

  new_item : (shop_url) ->
    item = new Shangjieba.Models.Item(shop_url : shop_url)
    view = new Shangjieba.Views.ItemNew({model:item})
    $('#data').html(view.render().el)

  show_item : (shop_url, url) ->
    item = new Shangjieba.Models.Item(shop_url : shop_url, url : url)
    item.fetch(
      success : () ->
        view = new Shangjieba.Views.ItemShow({model:item})
        $('#data').html(view.render().el)
      )

  new_discount : (shop_url) ->
    discount = new Shangjieba.Models.Discount(shop_url : shop_url)
    view = new Shangjieba.Views.DiscountNew({model : discount})
    $('#data').html(view.render().el)

  show_discount : (shop_url, url) ->
    # discount = new Shangjieba.Models.Discount(shop_url : shop_url, url : url)
    # discount.fetch(
    #   success : () ->
    #     view = new Shangjieba.Views.DiscountShow({model:discount})
    #     $('#data').html(view.render().el)
    #   )
