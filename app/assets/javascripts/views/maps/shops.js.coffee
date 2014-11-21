class Shangjieba.Views.ShopsMap extends Backbone.View
  initialize: (option) ->
    _.bindAll(this, "render");
    this.shops = option.colletion
    this.shops.bind("change", @render)

  render: ->
    this.map = new BMap.Map("map_canvas");
    point = new BMap.Point(121.4, 31.2);
    this.map.centerAndZoom(point,13);    
    pois = new Array()
    points = this.shops.get_coordinates();
    for coords in points
      if coords.lon != null and coords.lat != null and coords.lon.match(/^[1-9]\d*\.\d+$/) != null and coords.lat.match(/^[1-9]\d*\.\d+$/) != null
        p = new BMap.Point(coords.lon, coords.lat)
        pois.push( p)
        marker = new BMap.Marker(p)
        this.map.addOverlay(marker)   

    this.map.setViewport(pois)
    this.map.addControl(new BMap.NavigationControl());
    this
