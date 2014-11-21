class Shangjieba.Views.ShopEdit extends Backbone.View
  initialize: ->
    _.bindAll(this, "render");
    @model.bind("change", @render)
 
  template: JST['shops/edit']

  events:
    "submit form" : "save"

  save: ->
    @model.set(
      "name" : this.$("[name=name]").val()
      "city" : this.$("[name=city]").val()
      "district" : this.$("[name=district]").val()
      "town" : this.$("[name=town]").val()
      "street" : this.$("[name=street]").val()
      "house_number" : this.$("[name=house_number]").val()
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