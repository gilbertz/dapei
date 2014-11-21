class Shangjieba.Views.ItemNew extends Backbone.View
  initialize: ->
    _.bindAll(this, "render");
    @model.bind("change", @render)
 
  template: JST['items/new']

  events:
    "submit form" : "save"

  save: ->
    @model.set(
      "title" : this.$("[name=title]").val()
      "description" : this.$("[name=description]").val()
      "price" : this.$("[name=price]").val()
      "discount" : this.$("[name=discount]").val()
      )
    @model.save({},
      success:
        _.bind(
          (model, response)->
            if response.errors
              @model = model
            else
              ShopsApp.router.navigate("#show/" + @model.get('shop_url'), true)
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
    $(@el).html(@template(item: @model))
    this