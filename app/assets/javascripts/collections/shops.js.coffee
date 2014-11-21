class Shangjieba.Collections.Shops extends Backbone.Collection
  model: Shangjieba.Models.Shop
  url: "shops"

  get_coordinates: ->
    coords = _.map(@models, (shop) ->
      lat = shop.get("weidu")
      lon = shop.get("jindu")
      lon:lon
      lat:lat
    )
    coords
