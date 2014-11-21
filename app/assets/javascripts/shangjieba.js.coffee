window.Shangjieba =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: -> 

$(document).ready ->
  Shangjieba.initialize()

#https://gist.github.com/1610397
#https://gist.github.com/1821349
Backbone.Model::nestCollection = (model, attributeName, nestedCollection) ->
  #setup nested references
  for item, i in nestedCollection
    model.attributes[attributeName][i] = nestedCollection.at(i).attributes

  #create empty arrays if none
  nestedCollection.bind 'add', (initiative) =>
    if !model.get(attributeName)
      model.attributes[attributeName] = []
    model.get(attributeName).push(initiative.attributes)

  nestedCollection.bind 'remove', (initiative) =>
    updateObj = {}
    updateObj[attributeName] = _.without(model.get(attributeName), initiative.attributes)
    model.set(updateObj)

  nestedCollection