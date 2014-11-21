class Shangjieba.Views.ShopNew extends Backbone.View
  initialize: ->
    ac = new BMap.Autocomplete
      "input" : "suggestId"
      "location" : "上海"
 
    ac.addEventListener "onconfirm", (e) ->
      _value = e.item.value
      myValue = _value.province + _value.city + _value.district + _value.street + _value.business
      $("[name=city]").val(_value.city)
      $("[name=district]").val(_value.district)
      $("[name=street]").val(_value.street)
      $("[name=name]").val(_value.business)
 
      myGeo = new BMap.Geocoder()
      myGeo.getPoint myValue, ((point) ->
        if point
          map = new BMap.Map("map_canvas") 
          map.centerAndZoom point, 16
          market = new BMap.Marker(point)
          map.addOverlay market
          market.enableDragging true
          market.addEventListener "dragend", ->
            marketpoint = market.getPoint()
            alert(marketpoint.lng + "," + marketpoint.lat)
            $("[name=jindu]").val(marketpoint.lng)
            $("[name=weidu]").val(marketpoint.lat)

          $("[name=jindu]").val(point.lng)
          $("[name=weidu]").val(point.lat)
        ), "上海"
      
    _.bindAll(this, "render");
    @model.bind("change", @render)
 
  template: JST['shops/new']

  events:
    "submit form" : "save"

  setPlace = ->
    alert(myvalue)

  save: ->
    @model.set(
      "url" : this.$("[name=url]").val()
      "name" : this.$("[name=name]").val()
      "city" : this.$("[name=city]").val()
      "district" : this.$("[name=district]").val()
      "town" : this.$("[name=town]").val()
      "street" : this.$("[name=street]").val()
      "house_number" : this.$("[name=house_number]").val()
      "jindu" : this.$("[name=jindu]").val()
      "weidu" : this.$("[name=weidu]").val()
      )
    @model.save({},
      success:
        _.bind(
          (model, response)->
            if response.errors
              @model = model
            else
              ShopsApp.router.navigate("", true)
          this)
      error:
        (model, response)->
          # TODO show popup window instead of alert
          if response.status == 0
            alert("失去与服务器的连接")
          else if response.status == 401
            alert("需要登陆")
          else if response.status == 403
            alert("权限不足")
          else
            alert("未知错误 " + JSON.stringify(response))
        )
    return false

  render: ->
    $(@el).html(@template(shop: @model))
    this
