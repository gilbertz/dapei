jQuery(document).ready(function(){
    jQuery("body").on("click", "#area", function(){

        console.log("-----------------");

        if(jQuery("#area-for-select").css("display") == "none"){
            jQuery("#area").find(".caret-b").addClass("caret-b-y").removeClass("caret-b");
        }else{
            jQuery("#area").find(".caret-b-y").addClass("caret-b").removeClass("caret-b-y");
        }

        jQuery("#area-for-select").slideToggle("slow");
    });

    jQuery(".area-for-select-nav ul li").click(function(){

        var d = jQuery(this).attr("data_to");

        jQuery(".area-for-select-conetnt").find(".active-area").removeClass("active-area");
        jQuery("#"+d).addClass("active-area");

        jQuery(".area-for-select-nav ul").find(".active").removeClass("active");
        jQuery(this).addClass("active");
        return false;
    });

    jQuery(".search_select").hover(function(){
            jQuery(".search_select .child-nav").css("display", "block");
        },function(){jQuery(".search_select .child-nav").css("display", "none");}
    );

    jQuery("#head-search .shopitem").click(function(){
        var newval=jQuery(this).text();
        jQuery(".search_select .bar .cat").text(newval);
        var form=jQuery(".search_f");
        var index = form.find('input[name="index"]');
        index.val("shop");
        jQuery(".search_select .child-nav").css("display", "none");
    });
    jQuery("#head-search .baobeiitem").click(function(){
        var newval=jQuery(this).text();
        jQuery(".search_select .bar .cat").text(newval);
        var form=jQuery(".search_f");
        var index = form.find('input[name="index"]');
        index.val("item");
        jQuery(".search_select .child-nav").css("display", "none");
    });
    jQuery("#head-search .discountitem").click(function(){
        var newval=jQuery(this).text();
        jQuery(".search_select .bar .cat").text(newval);
        var form=jQuery(".search_f");
        var index = form.find('input[name="index"]');
        index.val("discount");
        jQuery(".search_select .child-nav").css("display", "none");
    });
    jQuery("#head-search .dapeiitem").click(function(){
        var newval=jQuery(this).text();
        jQuery(".search_select .bar .cat").text(newval);
        var form=jQuery(".search_f");
        var index = form.find('input[name="index"]');
        index.val("dapei");
        jQuery(".search_select .child-nav").css("display", "none");
    }); 


    jQuery(".child-nav li").hover(function(){
        jQuery(this).addClass("nav-active");
    }, function(){
        jQuery(this).removeClass("nav-active");
    });

    //我的主页
    jQuery("#my-home-li").hover(function(){
        jQuery("#my-home-li .child-nav").css("display", "block");
    },function(){
        jQuery("#my-home-li .child-nav").css("display", "none");
    });


    jQuery("#navbar-top-ul > li").click(function(){

        if(jQuery("#nav-b-top-not-home").css("display") == "none"){
            jQuery("#navbar-top-ul").find(".caret-w").addClass("caret-w-y").removeClass("caret-w");
        }else{
            jQuery("#navbar-top-ul").find(".caret-w-y").addClass("caret-w").removeClass("caret-w-y");
        }

        jQuery("#nav-b-top-not-home").slideToggle("slow");
    });

    jQuery(".click-scroll-down").click(function(){
        var el = jQuery(jQuery(this).parent().find(".click-scroll ul")[0]);
        scroll_up_down(el, 240, 1, 30);
    });

    jQuery(".click-scroll-up").click(function(){
        var el = jQuery(jQuery(this).parent().find(".click-scroll ul")[0]);
        scroll_up_down(el, 240, -1, 30);
    });
    jQuery(".about-menu").click(function(){
        item_id = jQuery(this).data("item");        
        if(jQuery("#"+item_id).css("display") == "none"){
            jQuery("#"+item_id).parent().find(".about-caret-w").addClass("about-caret-w-y").removeClass("about-caret-w");
        }else{
            jQuery("#"+item_id).parent().find(".about-caret-w-y").addClass("about-caret-w").removeClass("about-caret-w-y");
        }
        jQuery("#"+item_id).slideToggle("slow"); 
    });
    jQuery("#_users_hisaibaobei_site_helps_admin_help_name").change(function(){
      if(this.value != ""){
        window.location.href="?id="+this.value;
      }
    });
});

//友情连接滚动
$(function(){
    $("#hello_friend").updownSlide({line:1, speed:500, timerInterval: 4000});
});

$(document).ready(function(){
	$(".chunk-one-left-nav li").mouseover(function(){
		var data_to = $(this).attr("data-to");
		var active_id = $("#chunk-one-main ul.active-active").attr("id");
        $(".chunk-one-left-nav").find("li.active").removeClass("active");
		$(this).addClass("active");
        $("#nav_flexslider").css("top", -data_to*370)

	});

//	$(".click-scroll-down").click(function(){
//        var el = $($(this).parent().find(".click-scroll ul")[0]);
//        scroll_up_down(el, 240, 1, 30);
//	});
//
//    $(".click-scroll-up").click(function(){
//        var el = $($(this).parent().find(".click-scroll ul")[0]);
//        scroll_up_down(el, 240, -1, 30);
//    });

    //鼠标划过即切换大图
    $(".b-bottom-ul li").hover(function(){
        $(this).click();
    });

    $(".click-scroll > .wrapper-ul > ul > li").on("mouseenter", function(){
        $(this).addClass("active");
    });

    $(".click-scroll > .wrapper-ul > ul > li").on("mouseleave", function(){
        $(this).removeClass("active");
    });

//    //我的主页
//    $("#my-home-li").hover(function(){
//        $("#my-home-li .child-nav").css("display", "block");
//    },function(){
//        $("#my-home-li .child-nav").css("display", "none");
//    });

    //more area
    $(".area-more-li").click(function(){
        var el = $(this).parent().find(".select-area-list");
        if(el.css("height") == "26px"){
            el.css("height", "auto");
        }else{
            el.css("height", "26px");
        }
    });
    //item index mouse hover show opacity-big
//    $(".stream li").on("hover", function(){
//        $(this).addClass("active-hover");
//    }, function(){
//        $(this).removeClass("active-hover");
//    });

    $(".stream > li.infli").on("mouseenter", function(){
        $(this).addClass("active-hover");
    });

    $(".stream > li.infli").on("mouseleave", function(){
        $(this).removeClass("active-hover");
    });


    //select-area-list height 26px or auto
    $(".select-area-list").each(function(){
        var h = parseInt($(this).css("height"));
        if(h > 26){
            $(this).css("height", "26px");
        }else{
            $(this).parent().find(".icon-more").hide();
        }
    });

    //price-input
    $(".price-input").focusin(function(){
        $(".price-select-span").addClass("active-focus");
        $(".cancel-submit").show();
    });

    //cancel-price
    $(".cancel-price").click(function(){
        $(".price-input").val("");
        $(".cancel-submit").hide();
        //return false;
    });

    $('input.price-input').bind('keydown', function(e){
        DigitInput(this, e);
    });

//    $(".shop-tool").on("mouseenter", function(){
//        $(this).addClass("shop-tool-active");
//    });
//
//    $(".shop-tool").on("mouseleave", function(){
//        $(this).removeClass("shop-tool-active");
//    });

    // shop index  show comment
    $("#shop-comment").click(function(){
        var b_c = $(this).find("#caret-b");
        var el = $("#comment_content");

        if(el.css("display") == "none"){
            $(".second-img-head").find(".caret-w-y").removeClass("caret-w-y").addClass("caret-w");
            b_c.removeClass("caret-w").addClass("caret-w-y");
            $(".second-img").find(".active").css("display", "none");
            $(".second-img").find(".active").removeClass("active");
            el.addClass("active");
        }else{
            b_c.removeClass("caret-w-y").addClass("caret-w");
        }
        el.slideToggle("slow");
    });

    // shop baidu
    $("#shop-map").click(function(){
        var b_c = $(this).find("#caret-b");
        var el = $("#baidu_map");

        if(el.css("display") == "none"){
            $(".second-img-head").find(".caret-w-y").removeClass("caret-w-y").addClass("caret-w");
            b_c.removeClass("caret-w").addClass("caret-w-y");
            $(".second-img").find(".active").css("display", "none");
            $(".second-img").find(".active").removeClass("active");
            el.addClass("active");
        }else{
            b_c.removeClass("caret-w-y").addClass("caret-w");
        }

        el.slideToggle("slow");
    });

    // shop other
    $("#other-shop-span").click(function(){
        var b_c = $(this).find("#caret-b");
        var el = $("#other-shop-tab");

        if(el.css("display") == "none"){
            $(".second-img-head").find(".caret-w-y").removeClass("caret-w-y").addClass("caret-w");
            b_c.removeClass("caret-w").addClass("caret-w-y");
            $(".second-img").find(".active").css("display", "none");
            $(".second-img").find(".active").removeClass("active");
            el.addClass("active");
        }else{
            b_c.removeClass("caret-w-y").addClass("caret-w");
        }

        el.slideToggle("slow");
    });

    // shop other
    $("#brand-info").click(function(){
        var b_c = $(this).find("#caret-b");
        var el = $("#brand-info-tab");

        if(el.css("display") == "none"){
            $(".second-img-head").find(".caret-w-y").removeClass("caret-w-y").addClass("caret-w");
            b_c.removeClass("caret-w").addClass("caret-w-y");
            $(".second-img").find(".active").css("display", "none");
            $(".second-img").find(".active").removeClass("active");
            el.addClass("active");
        }else{
            b_c.removeClass("caret-w-y").addClass("caret-w");
        }

        el.slideToggle("slow");
    });

    //other-shop-span
    $(".other-shop-span").click(function(){
        $(".other-shop-ul").toggle();
    });


    // navbar-top-ul
//    $("#navbar-top-ul > li").click(function(){
//
//        if($("#nav-b-top-not-home").css("display") == "none"){
//            $("#navbar-top-ul").find(".caret-w").addClass("caret-w-y").removeClass("caret-w");
//        }else{
//            $("#navbar-top-ul").find(".caret-w-y").addClass("caret-w").removeClass("caret-w-y");
//        }
//
//        $("#nav-b-top-not-home").slideToggle("slow");
//    });

//    $(".area-for-select-nav ul li").click(function(){
//
//        var d = $(this).attr("data_to");
//
//        $(".area-for-select-conetnt").find(".active-area").removeClass("active-area");
//        $("#"+d).addClass("active-area");
//
//        $(".area-for-select-nav ul").find(".active").removeClass("active");
//        $(this).addClass("active");
//        return false;
//    });

//    $("body").on("click", "#area", function(){
//
//        console.log("-----------------");
//
//        if($("#area-for-select").css("display") == "none"){
//            $("#area").find(".caret-b").addClass("caret-b-y").removeClass("caret-b");
//        }else{
//            $("#area").find(".caret-b-y").addClass("caret-b").removeClass("caret-b-y");
//        }
//
//        $("#area-for-select").slideToggle("slow");
//    });
    $(".hide-tool").click(function(){

        $(this).parent().find(".info-hide").toggle();
    });
});

function DigitInput(el,e) {
    var e = e || window.event;
    var cod = e.charCode||e.keyCode;
    //小数点处理
    if (cod == 110 || cod == 190){
        (el.value.indexOf(".")>=0 || !el.value.length) && notValue(e);
    } else {
        if(cod!=8 && cod != 46 && (cod<37 || cod>40) && (cod<48 || cod>57) && (cod<96 || cod>105)){
            notValue(e);
        }else{
            $(el).css("border", "1px solid #abadb3");
        }
    }
    function notValue(e){
        $(el).css("border", "1px solid red");
        e.preventDefault ? e.preventDefault() : e.returnValue=false;
    }
}

$(window).load(function(){
  $('#banner-center .flexslider').flexslider({
    animation: "slide",
    directionNav: false,
    manualControls: ".b-bottom-ul li",
    after: function(){
        var bgc = $(".flex-viewport").find(".flex-active-slide").attr("bgc");
        $("#banner").css("background", "#"+bgc);
    },
  });
});

function scroll_up_down(obj, scroll_height, flag, one_height){

    var scroll_height = scroll_height;
    var flag = flag;
    var one_height = one_height;

    if(flag > 0){
		var obj_height = parseInt(obj.height());
        var now_top = obj.css("top");
        var can_scroll_height;

        if(now_top == "" || now_top == "auto"){
            now_top = 0;
        }
        now_top = parseInt(now_top);
		if(obj_height <= 240){
			return false;
		}

		if(Math.abs(now_top) >= (obj_height - 240)){
			return false;
		}

        if(obj_height - now_top < 240){
            can_scroll_height = obj_height - now_top;
        }else{
            can_scroll_height = 240;
        }

        obj.css("top", now_top - can_scroll_height);

        var nav_hover_now_top = $(".nav-hover").css("top");
        if(nav_hover_now_top == "" || nav_hover_now_top == "auto"){
            nav_hover_now_top = 0;
        }
        nav_hover_now_top = parseInt(nav_hover_now_top);
        $(".nav-hover").css("top", 240 + nav_hover_now_top);
	}else{
        var obj_height = parseInt(obj.height());
        var now_top = obj.css("top");
        var can_scroll_height;

        if(now_top == "" || now_top == "auto"){
            now_top = 0;
        }
        now_top = parseInt(now_top);
        if(obj_height <= 210){
            return false;
        }

        if(now_top >= 0){
            return false;
        }

        if(obj_height - now_top < 240){
            can_scroll_height = obj_height - now_top;
        }else{
            can_scroll_height = 240;
        }

        obj.css("top", now_top + can_scroll_height);

        var nav_hover_now_top = $(".nav-hover").css("top");
        if(nav_hover_now_top == "" || nav_hover_now_top == "auto"){
            nav_hover_now_top = 0;
        }
        nav_hover_now_top = parseInt(nav_hover_now_top);
        $(".nav-hover").css("top", nav_hover_now_top - 240);
	}
}

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
    /*
    $(".chunk-one-ul li").hover(function(){
       var item=$(this).find(".opacity-big");
       item.css("display", "none");}, function(){
       $(this).find(".opacity-big").css("display", "block"); 
    });*/
});

$(function(){
//    $(".search_select").hover(function(){
//        $(".search_select .child-nav").css("display", "block");
//        },function(){$(".search_select .child-nav").css("display", "none");}
//    );
    //搜索下拉分类hover
//    $(".child-nav li").hover(function(){
//        $(this).addClass("nav-active");
//    }, function(){
//        $(this).removeClass("nav-active");
//    });
    //上下选择地区品牌..
    $(".click-scroll-down").hover(function(){
        $(this).find("img").attr("src", "/assets/newweb/arrows-bottom-red.png");
    }, function(){
        $(this).find("img").attr("src", "/assets/newweb/arrows-bottom.png");
    });
    $(".click-scroll-up").hover(function(){
        $(this).find("img").attr("src", "/assets/newweb/arrows-top-red.png");
    }, function(){
        $(this).find("img").attr("src", "/assets/newweb/arrows-top.png");
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

function goPriceSearch(){
  var low_price = $('input[name="low_price"]').val();
  var high_price =  $('input[name="high_price"]').val();
  location.href = "?low_price=" + low_price + "&high_price=" + high_price;
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
    
    /* 
    $container.masonry({
        singleMode      : true,
        //columnWidth     : 504,
        itemSelector    : '.infli',
        animate         : true,
        animationOptions: {
            duration: speed,
            queue   : false
        }
    });
    */

    //无限滚动
    $('.stream').infinitescroll({
        navSelector    : "#page_nav",
        nextSelector   : "#page_nav a",
        itemSelector   : ".infli",
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
            //$container.masonry( 'appended', $newElems, true );
        });

})

//The navigation select.
$(function() {
  $('#navbar-center li a').each(function() {
    //alert("!!");
    if (jQuery(this).attr('href')  ===  window.location.pathname) {
      jQuery(this).parent().addClass('active');
    }
  });
});
//]]>

//The backtotop
$(function() {
        $(window).scroll(function() {
                if($(this).scrollTop() >300) {
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
                $('body,html').animate({scrollTop:0},100);
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
  $('.lover_icon').on('click', function(){
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
  $('.item_lover_icon').on('click', function(){
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
  $('.shop_lover_icon').on('click', function(){
      var target_type = $(this).find("a:first").attr("liked_type");
      var target_id = $(this).find("a:first").attr("liked_id");
      var likes_count = $(this).find("a:first").attr("likes_count");
      var elem = $(this).find(".like_num")
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
  $('.dapei_lover_icon').bind('click', function(){
      var target_type = $(this).find("a:first").attr("liked_type");
      var target_id = $(this).find("a:first").attr("liked_id");
      var likes_count = $(this).find("a:first").attr("likes_count");
      var elem = $(this).find(".like_num")
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
    //alert("now here");
    //$("#chaoyangCounts").css("display","block");
    //$(this).addClass("hover");
    var elem = $(this).find(".menu-hd");
    //var num = elem.attr("num");
    var dp_id = elem.attr("dp_id");
    var panel1=$(".nav-hover .first ul");
    var panel2=$(".nav-hover .second ul");
    var panel3=$(".nav-hover .third ul");
    var panel4=$(".nav-hover .fourth ul");
    //if (num>8)
       //panel.addClass("right-panel");
    //else
    //   panel.removeClass("right-panel");
    $.ajax({url: "/shop/info/group_by_street.json?dp_id="+dp_id,
           type: 'GET',
           success: function(data) {
               panel1.empty();
               panel2.empty();
               panel3.empty();
               panel4.empty();
               var num=0
               $.each(data.dat, function(k, v){
                   if (num<8){
                     panel1.append(
                       "<li><a href=\"/shop/_street___" + v.street + "_a"+ dp_id + ".html\">" + v.street + "</a></li>"
                     );
                   }
                   else if(num<16){
                    panel2.append(
                       "<li><a href=\"/shop/_street___" + v.street + "_a"+ dp_id + ".html\">" + v.street + "</a></li>"
                     );
                   }
                   else if(num<24){
                    panel3.append(
                       "<li><a href=\"/shop/_street___" + v.street + "_a"+ dp_id + ".html\">" + v.street + "</a></li>"
                     );
                   }
                   else{
                    panel4.append(
                       "<li><a href=\"/shop/_street___" + v.street + "_a"+ dp_id + ".html\">" + v.street + "</a></li>"
                     );
                   }
                   num=num+1;
               })
              }
           });
    },function(){
        $(this).removeClass("hover");
        //$("#chaoyangCounts").css("display","none")
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


//友情链接滚到
(function($){
    $.fn.updownSlide = function(settings){
        settings = jQuery.extend({
            speed: "normal",
            line: 1,
            timerInterval: 2000
        }, settings);

        return this.each(function(){
            $.fn.updownSlide.scroll($(this), settings);
        });
    }

    $.fn.updownSlide.scroll = function($this, settings){
        var ul = $("ul:eq(0)", $this);
        ul.hover(
            function(){
                clearInterval(timerHandler);
            },
            function(){
                timerHandler = setInterval(function(){
                    var li = ul.find("li:first");
                    var height = li.height();
                    li.stop(true).animate({marginTop: -height+'px'}, settings.speed, function(){
                        li.css("marginTop", 0).remove().appendTo(ul);
                    });
                }, settings.timerInterval);
            }
        ).trigger("mouseleave");
    }
})(jQuery);
