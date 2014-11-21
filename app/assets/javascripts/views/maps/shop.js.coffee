class Shangjieba.Views.MapShow extends Backbone.View
  initialize: (option) ->
    _.bindAll(this, "render");
    this.model = option.model
    this.model.bind("change", @render)

  render: ->
    this.map = new BMap.Map("map_canvas");
    lon = this.model.get('jindu')
    lat = this.model.get('weidu')
    point = new BMap.Point(lon, lat);
    this.map.centerAndZoom(point,13);
    this.map.enableScrollWheelZoom();
    this.map.addOverlay(new BMap.Marker(point));
    this
