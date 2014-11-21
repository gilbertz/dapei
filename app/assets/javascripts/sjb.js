/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */


$(function(){
    //我的首页 
    $("#myIndex").hover(function(){
	$(this).addClass("hover");
	},function(){$(this).removeClass("hover");}
     );
     //我的消息 
    $("#myMessage").hover(function(){
	$(this).addClass("hover");
	},function(){$(this).removeClass("hover")}
    );
     //登录方式
    $("#loginType").hover(function(){
	$(this).addClass("hover");
	},function(){$(this).removeClass("hover")}
    );
    //更多子分类
    $("#moreClass").hover(function(){
	$(this).addClass("hover");
        },function(){$(this).removeClass("hover")}
    );

    $(".rightbar .codebtn").hover(function(){
        $("#leftbar").css("display", "block");
        },function(){$("#leftbar").css("display", "none");}
    );
    $("#chaoyangCounts").hover(
	function(){
 	  $("#showChaoyangCounts").addClass("hover");  
	  $(this).css("display","block");
	},function(){
	   $(this).css("display","none");
	   $("#showChaoyangCounts").removeClass("hover"); 
	}
     );
});

$(function(){
    $(".search_select").hover(function(){
        $(".search_select .child-nav").css("display", "block");
        },function(){$(".search_select .child-nav").css("display", "none");}
    );
    $("#head-search .shopitem").click(function(){
        var newval=$(this).text();
        $(".search_select .bar .cat").text(newval);
        var form=$(".search_f");
        var index = form.find('input[name="index"]');
        index.val("shop");
        $(".search_select .child-nav").css("display", "none");
    });
    $("#head-search .baobeiitem").click(function(){
        var newval=$(this).text();
        $(".search_select .bar .cat").text(newval);
        var form=$(".search_f");
        var index = form.find('input[name="index"]');
        index.val("baobei");
        $(".search_select .child-nav").css("display", "none");
    });
    $("#head-search .discountitem").click(function(){
        var newval=$(this).text();
        $(".search_select .bar .cat").text(newval);
        var form=$(".search_f");
        var index = form.find('input[name="index"]');
        index.val("discount");
        $(".search_select .child-nav").css("display", "none");
    });
});

$(function(){
    $(".area_menu .left .area_list .mall_list .more").click(function(){
      var dis=$(".area_menu .left .area_list .mall_list .more_block");
      dis.toggle();
    });
    $(".area_menu .left .area_list .street_list .more").click(function(){
      var par=$(".area_menu .left .area_list .street_list .more_block");
      par.toggle();
    });
});

function goSearch(){
  var form=$(".search_form");;
  var q = form.find('input[name="q"]').val().replace(/\./g, "");
  var index =  form.find('input[name="index"]').val();
  location.href = "/" + index + "/_" + q + ".html";
}


$(function(){
    $(".pl_btn").click(function(){
        $('.text_box').css('display', 'block');
        var $container = $('.stream');
        $container.masonry( 'reload');   
    });
});



jQuery(document).ready(function($) {
  $.facebox.settings.opacity = 0.75;
  $('a[rel*=facebox]').facebox() 
}) 

$(function(){
    //瀑布流
    var speed      = 1000;
    var $container = $('.stream');
    //$('#page_nav').css('display', 'none');

    $container.masonry({
        singleMode      : true,
        //columnWidth     : 504,
        itemSelector    : '.shopli',
        animate         : true,
        animationOptions: {
            duration: speed,
            queue   : false
        }
    });

    //无限滚动
    $('.stream').infinitescroll({
        navSelector    : "#page_nav",
        nextSelector   : "#page_nav a",
        itemSelector   : ".stream .infli",
        debug          : false,
        loadingImg     : '/assets/static-loader.png',
        loadingText    : "<em>加载更多</em>",
        donetext       : "<em>没有更多的了</em>",
        errorCallback  : function() {
            $('#infscr-loading').animate({opacity: .8},2000).fadeOut('normal');
        }},
        function( newElements ) {
            var $newElems = $( newElements ).css({ opacity: 0 });
            $newElems.animate({ opacity: 1 });
            $container.masonry( 'appended', $newElems, true );
        }); 
    
})

//The navigation select.
$(function() {
  $('.nav_box .nav  li a').each(function() {
    //alert("!!");
    if (jQuery(this).attr('href')  ===  window.location.pathname) {
      jQuery(this).addClass('select');
    }
  });
});  
//]]>

//The backtotop
$(function() {
	$(window).scroll(function() {
		if($(this).scrollTop() >100) {
			$('#toTop').fadeIn();	
		} else {
			$('#toTop').fadeOut();
		}
                if($(this).scrollTop() >200) {
                        $('.gjb_bottom').fadeIn();
                } else {
                        $('.gjb_bottom').fadeOut();
                }
	});
 
	$('#toTop').click(function() {
		$('body,html').animate({scrollTop:0},800);
	});	
});


function show_map(){
    $("#shop_map").css("display","block");
    var map = new BMap.Map("shop_map");
    var lng = $("input[name='shop[jindu]']").val();
    var lat = $("input[name='shop[weidu]']").val();
    if (lng !="" && lat !=""){
      var url = "/shops/info/map_address?lng="+lng+"&lat="+lat
      $("#map_address").attr("href", url);

      var point = new BMap.Point(lng, lat);
      map.centerAndZoom(point, 17);
      var market=new BMap.Marker(point);
      map.addOverlay(market); //建立一个标注
    }
}

$(function() {
  $('.lover_icon').live('click', function(){
      var target_type = $(this).find("a:first").attr("liked_type");
      var target_id = $(this).find("a:first").attr("liked_id");
      var likes_count = $(this).find("a:first").attr("likes_count");
      var elem = $(this).find("a:first")
      $.ajax({url: "/social/likes",
           type: 'POST',
           data: { like: {target_type:target_type, target_id:target_id } },
           success: function() {
                 elem.text(elem.text().replace(/(\d+)/, function(match){ return parseInt(match) + 1; }));
                 //elem.text(updated_count + "人喜欢")
              }
           });
      });
});

$(function() {
  $('.lover_btn').bind('click', function(){
    var target_type = $(this).attr("liked_type");
    var target_id = $(this).attr("liked_id");
    var likes_count = $(this).attr("likes_count");
    var elem = $(this).next()
    $.ajax({url: "/social/likes",
           type: 'POST',
           data: { like: {target_type:target_type, target_id:target_id } },
           success: function() {
                 elem.text(elem.text().replace(/(\d+)/, function(match){ return parseInt(match) + 1; }));
                 //elem.text(updated_count + "人喜欢")
              }
           });
    });
});


$(function() {
  $('.showChaoyangCounts').hover(function(){
    $("#chaoyangCounts").css("display","block");
    $(this).addClass("hover"); 
    var elem = $(this).find(".menu-hd");
    var num = elem.attr("num");
    var dp_id = elem.attr("dp_id");
    var panel=$("#chaoyangCounts .panel");
    if (num>8)
       panel.addClass("right-panel");
    else
       panel.removeClass("right-panel");
    $.ajax({url: "/shop/info/group_by_street.json?dp_id="+dp_id,
           type: 'GET',
           success: function(data) {
               panel.empty();
               $.each(data.dat, function(k, v){
                   panel.append(
                     "<li><a href=\"/shop/_street___" + v.street + "_a"+ dp_id + ".html\">" + v.street + "(" + v.count + ")</a></li>"
                   );
               })

               panel.append("<div class=\"streets\"> </div>");         
               var streets=panel.find(".streets");     
               $.ajax({url: "/shop/info/group_by_brand.json?dp_id=a"+dp_id,
                   type: 'GET',
                   success: function(data){
                       $.each(data.dat, function(k, v){
                           streets.append(
                             "<li><a href=\"/shop/_brand___" + v.brand_name + "_a" + dp_id + ".html\">" + v.brand_name + "(" + v.count + ")</a></li>"
                           );
                       });
                       //panel.append("</div")
                   }
               });  

              }
           });
    },function(){
        $(this).removeClass("hover");
        $("#chaoyangCounts").css("display","none")
    });

})

$(function() {
  $("#suggestId").blur(function(){
    var addr = $("input[name='address']").val();
    if ( addr == "" ){
      url = "#"
      $("#map_address").attr("href", url);
      return;
    }
    var dist = "上海市" + $("#dist").find("option:selected").attr('dist');
    var myGeo = new BMap.Geocoder();
    myGeo.getPoint(dist+addr, function(point){
      if (point) {
        url = "/shops/info/map_address?lng="+point.lng+"&lat="+point.lat
        $("#map_address").attr("href", url);
        $("input[name='shop[jindu]']").val( point.lng );
        $("input[name='shop[weidu]']").val( point.lat );
      }else{
        //alert("你输入的地址正确吗?");
      }
    }, "全国");
  
  });
});

/*
$(function(){
      $('#carousel').flexslider({
        animation: "slide",
        controlNav: false,
        animationLoop: false,
        slideshow: false,
        itemWidth: 60,
        //itemMargin: 5,
        asNavFor: '#slider'
      });
      
      $('#slider').flexslider({
        animation: "slide",
        controlNav: false,
        animationLoop: false,
        slideshow: false,
        sync: "#carousel",
        start: function(slider){
          $('body').removeClass('loading');
        }
      });
});
*/

//$(window).load(function(){
$(function() {
  $('#first_page').flexslider({
    animation: "slide",
    controlNav: "thumbnails",
    start: function(slider){
      $('body').removeClass('loading');
    }
  });
});

$(function() {
  $('#create_item_btn').bind('click', function(){
      //alert("test for test");
      var form=$("#create_item_form");
      var submitButton = form.find('input[name="commit"]');
      var photos=form.find('input[name="photos[]"]');
      if (photos.length<1){
          $(this).attr('disabled', 'disabled');
          $('body,html').scrollTop(300);
          $('#warning').css("display","block");
          $('.upload .warning').css("display","inline-block");
          return false;
      }
      else{
          submitButton.removeAttr('disabled');
      }
  });
});

$(function() {
  $('#create_shop_btn').bind('click', function(){
      //alert("test for test");
      var form=$("#create_shop_form");
      var submitButton = form.find('input[name="commit"]');
      var photos=form.find('input[name="photos[]"]');
      if (photos.length<1){
          $(this).attr('disabled', 'disabled');
          $('body,html').scrollTop(300);
          $('#warning').css("display","block");
          $('.upload .warning').css("display","inline-block");
          return false;
      }
      else{
          submitButton.removeAttr('disabled');
      }
  });
});

$(function() {
  $('#create_post_btn').bind('click', function(){
      //alert("test for test");
      var form=$("#create_post_form");
      var submitButton = form.find('input[name="commit"]');
      var photos=form.find('input[name="photos[]"]');
      if (photos.length<1){
          $(this).attr('disabled', 'disabled');
          $('body,html').scrollTop(300);
          $('#warning').css("display","block");
          $('.upload .warning').css("display","inline-block");
          return false;
      }
      else{
          submitButton.removeAttr('disabled');
      }
  });
});


$(function() {
  $('#city').bind('change', function(){
      var city_id = $("#city").find("option:selected").val();
      var panel=$("#dist");
      $.ajax({url: "/areas/info/get_all_dist.json?city_id="+city_id,
           type: 'GET',
           success: function(data) {
               panel.empty();
               $.each(data.areas, function(k, v){
                   if( v.type == 'district' ){
                       panel.append(
                           "<option dist='"+v.name+"' value='" + v.id + "'>" + v.name+"</option>"
                       );
                   }else{
                       panel.append(
                           "<option dist='"+v.name+"' value='" + v.id + "'>---" + v.name+"</option>"
                       );
                   }
               })
          } 
      });
  });
});


function BigImgNav(bigimg, lefturl, righturl) {
  var imgurl = righturl;
  var width = bigimg.width;
  var height = bigimg.height;
  bigimg.onmousedown = bigimg.onmousemove = function () {
    if (event.offsetX < width / 2) {
      imgurl = lefturl;
      if (imgurl != "#")
        bigimg.style.cursor = 'url(/assets/btn_pre-1.cur),auto';
      else
        bigimg.style.cursor = 'default';
    }
    else {
      imgurl = righturl;
      if (imgurl != '#')
        bigimg.style.cursor = 'url(/assets/btn_next-1.cur),auto';
      else
        bigimg.style.cursor = 'default';
    }
  }
 
  bigimg.onmouseup = function () {
    if (imgurl != '#')
      top.location = imgurl;
  }
}

function addBookmark(){
	var title="上街吧,最好的周边女装时尚指南, www.shangjieba.com";
	var url="http://www.shangjieba.com/?fav";
	if(window.sidebar){
		window.sidebar.addPanel(title,url,'');
	}else{
		try{
			window.external.AddFavorite(url,title);
		}catch(e){
			alert("您的浏览器不支持该功能,请使用Ctrl+D收藏本页");
		}
	}
}
