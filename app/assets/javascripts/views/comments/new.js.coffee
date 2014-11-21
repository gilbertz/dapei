class Shangjieba.Views.CommentNew extends Backbone.View
  template: JST['comments/new']

  events:
    "submit form" : "save"

  save: ->
    @model.set(
      "comment" : 
        "comment" : this.$("[name=comment]").val()
        "commentable_id" : @model.commentable.id
        "commentable_type" : @model.commentable.type
      )
    @model.save({},
      success:
        _.bind(
          ()->
            @model.commentable.comments.push(@model)
            @model.commentable.trigger("change")
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
    $(@el).html(@template())
    this