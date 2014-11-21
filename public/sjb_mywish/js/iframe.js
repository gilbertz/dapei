$(function() {
  sap.run();
  sap.communication.listenMessage();
});

/**
 * Namespace sap
 */
var sap = {
  run: function() {
    sap.UI.init();
  }
};

sap.iframeStatus = {
  login: 'loginPage',
  show: 'showPage',
  cancel: 'originPage',
  close: 'closeIframe'
};

sap.communication = function() {
  var lastHeight = 0;
  var lastStatus = '';

  function sendMessageByHash(target, message) {
    message = encodeURIComponent(message);
    var parentLocatoin = GLOBAL.URL.getURLParameter('ref');
    
    if (parentLocatoin) {
      parentLocatoin = parentLocatoin.split('#')[0];
    }
    
    target.location.href = parentLocatoin + '#' + message;
  }

  function isHeightChanged() {
    return document.body.scrollHeight !== lastHeight;
  }

  function isStatusChanged(status) {
    return lastStatus !== status;
  }

  return {
    postMessage: function(target, status) {
      if (isHeightChanged() || isStatusChanged(status)) {
        lastHeight = document.body.scrollHeight;
        lastStatus = status;
      } else {
        //no change, no need to update
        return;
      }
      var message = {"status": status};
      if (status === sap.iframeStatus.show) {
        message.height = document.body.scrollHeight;
      }
      message = JSON.stringify(message);
      if (target.postMessage) {
        target.postMessage(message, '*');
      } else {
        sendMessageByHash(target, message);
      }
    },
    listenMessage: function() {
      GLOBAL.listener.addDomListener(window, 'message', function(e) {
        var domain = location.protocol + "//" + location.host;
        if (e.origin == "https://api.weibo.com" || e.origin == "http://qzonestyle.gtimg.cn" || e.origin == "https://graph.qq.com") {
            
        }else if(e.origin == domain && e.data.indexOf('UserAccountVO') > -1){
             var resp = JSON.parse(e.data);
             GLOBAL.storage.saveItem('userAccountVO', JSON.stringify(resp), false);
             var expires = new Date().getTime() + resp.expireIn;
             
             GLOBAL.storage.saveItem('expires_in', expires, false);
             GLOBAL.storage.saveItem('userType', "QZONE", false);
             
             sap.capture(sap.postProduct);
             GLOBAL.storage.saveItem('accessToken', resp.accessToken, false);
             $("#login").addClass("hidden");
             if ($("#capture-result").hasClass("hidden")) {
                 $("#capture-result").removeClass("hidden");
             }
        }else {
            if (e.data && e.data.indexOf('sourceUrl') > -1) {
                var product = e.data.replace(/^#/, '');
                sap.postProduct = JSON.parse(product);
            }
            
            if (sap.status.isSignin()) {
                sap.capture(sap.postProduct);
                
                var userType = sap.status.isSignin(),
                    shareOnClass = "";
                switch(userType) {
                  case "SINAWEIBO":
                      shareOnClass = "weibo-on";
                      break;
                  case "QZONE":
                      shareOnClass = "qzone-on";
                      break;
                  case "FACEBOOK":
                      shareOnClass = "facebook-on";
                      break;
                  case "TWITTER":
                      shareOnClass = "twitter-on";
                      break;
                  default:
                      shareOnClass = "";
                      break;
                }
                if (shareOnClass) {
                    $("#share").addClass(shareOnClass);
                } else {
                    $("#share").hide();
                }
                
                if($("#close-btn").hasClass("hidden")) {
                    $("#close-btn").removeClass("hidden");
                }
                $("#close-btn").addClass("close-btn-capture-result");
                
                $("#capture-result").removeClass("hidden");
                
                var contentWrapperTop = $("div.content-wrapper").offset().top,
                    imageListTop = $("#image-list").offset().top,
                    CONTENT_WRAPPER_HEIGHT = 600,
                    LEFT_CONTENT_PADDING_BOTTOM = 30,
                    imageListHeight = CONTENT_WRAPPER_HEIGHT - (imageListTop - contentWrapperTop) - LEFT_CONTENT_PADDING_BOTTOM;
                    
                $("#image-list").height(imageListHeight);
                
                sap.scrollbar.init();
            } else {
                $("#login").removeClass("hidden");
                sns.login();
            }
        }
      });
    }
  };
}();

/**
 * Cache all product have been send to server
 * if create a liked item on server successfully, the response will be cached,
 * otherwise remove the product from cache.
 */
sap.cache = function() {
  var itemKey = [];//Collection of imagePath serve as index of item
  var items = [];//Array of item object

  function _indexOf(array, obj, start) {
    if (Array.indexOf) {
      return array.indexOf(obj, start);
    } else {
      for (var i = (start || 0); i < array.length; i++) {
        if (array[i] === obj) {
          return i;
        }
      }
      return -1;
    }
  }

  return {
    /**
     * Check the product with this imagePath whether have been captured
     * @param {string} The imagePath of product
     */
    isCapturedSuccess: function(imagePath) {
      return -1 !== _indexOf(itemKey, imagePath);
    },
    
    /**
     * Check is there a request sending.
     */
    isItemSending: function() {
      return !((0 === itemKey.length) || (items[itemKey.length - 1] && items[itemKey.length - 1].serverItem));
    },

    /**
     * Cache product relative information such as personalNotes. 
     * @param {object} Collection of product information
     */
    saveItem: function(item) {
      itemKey.push(item.product.imagePath);
      items.push(item);
    },

    /**
     * Query an item from cache by imagePath of product
     * @param {string} The imagePath of product
     */
    getItem: function(imagePath) {
      var index = _indexOf(itemKey, imagePath);
      return items[index];
    },

    /**
     * The method will be called after server response for the create ilike item ajax call
     * @param {object} Information of liked item, it is the response result of server creating liked item
     */
    updateServerItem: function(serverItem) {
      items[itemKey.length - 1].serverItem = serverItem;
    },
    
    /**
     * Remove the last element of cache. it will be called if the create item ajax called have not been responsed successfully
     */
    removeLastItem: function() {
      itemKey.pop();
      items.pop();
    }
  };
}()

sap.UI = function() {
  // Click prompt
  var prompt = document.getElementById('prompt');
  var capturedPrompt = document.getElementById('captured-prompt');

  // Login form
  var username = document.getElementById('username');
  //var password = document.getElementById('password');
  var formWrapper = document.getElementById('form-wrapper');
  //var backButton = document.getElementById('reset');
  //var loginButton = document.getElementById('signin');
  
  // Product detail
  var infoList = document.getElementById('info-list');
  var thumbnail = document.getElementById('thumbnail');
  var remark = document.getElementById('remark');
  var remarkOuterBox = document.getElementById('outer-box');
  var remarkLabel = document.getElementById('remark-label');
  
  return {
    /**
     * Initializes iframe
     */
    init: function() {
      this.prompt.show();
      this.loginForm.init();
      
      $('#close-btn').on('click', function () {
          onWindowResize.remove();
          sap.communication.postMessage(parent, sap.iframeStatus.close);
      });
      
      $('#submit_picture').on('click', function (e) {
          e.stopPropagation();
          
          if($('#loading').css('display') != 'none') {
              return false;
          }
          
          sap.messageBox.hideMsg();

          var passFlag = true;
          
          var category = $("#category").attr("categoryName");
          if(!category) {
              passFlag = false;
          }
          
          if ($('div.image-highlight').length > 0) {
              /* var hasSetCover = false;
              
              if ($('div.image-highlight').length == 1) {
                  hasSetCover = true;
              } else {
                  $('div.cover').each(function(){
                      if ($(this).text() == '取消封面') {
                          hasSetCover = true;
                          return;
                      }
                  });
              } */
              
              //if (hasSetCover) {
                  if (passFlag) {
                      $(this).addClass('disabled');
                      $('#loading').show();
                      
                      //var postUrl = GLOBAL.URL.getUrlByDomain('/condor-1/rest/myrunway/capture');
                      var postUrl = 'http://www.shangjieba.com:6004/spiders/create_sku';
                      sap.action.postData(postUrl);
                  } else {
                      sap.messageBox.showMsg(sapLang.getText('selectCategoryTip'));
                  }
              // } else {
                  // $imgValidationSpan.text('请先选择一张图片作为封面！');
              // }
          } else {
              sap.messageBox.showMsg(sapLang.getText('selectImageTip'));
          }
      });
      
      $('#cancel_picture').on('click', function () {
          $('#close-btn').click();
      });
      
      // iLike content div drag & drop
      var isMouseDown = false;
      var offsetX = 0;
      var offsetY = 0;
      var $iLikeDiv = $('#capture-result');
      
      $iLikeDiv.mousedown(function(e) {
          var event = window.event || e; //获取事件对象
          if(event.button != 2 && event.button != 3) {
              isMouseDown = true;
              $iLikeDiv.css("cursor", "pointer");
              offsetX = event.clientX - $(this).offset().left;
              offsetY = event.clientY - $(this).offset().top;
          }
      });
      
      $('#close-btn, #image-list, div.node-list, #category, #share, #operator a').mousedown(function(e) {
          isMouseDown = false;
          var event = window.event || e; //获取事件对象
          event.cancelBubble = true;
          event.returnValue = false; 
          $("#title input, #comment textarea").blur();
          
          return false;
      });
      
      $("#origin-info span, #origin-info i, #origin-info input, #comment").mousedown(function(e) {
          e.stopPropagation();
          isMouseDown = false;
      });
      
      $(document).mousemove(function(e) {
          var event = window.event || e; //获取事件对象
          if(isMouseDown) {
              $iLikeDiv.css("cursor", "move");
              
              var x = event.clientX - offsetX;
              var y = event.clientY - offsetY;
              $iLikeDiv.parent().offset({ top: y, left: x });
              
              event.cancelBubble = true;
              event.returnValue = false; 
              return false;
          }
      }).mouseup(function() {
          isMouseDown = false;
          $iLikeDiv.css("cursor", "default");
      });
      
      $('body').on("click", function() {
          sap.messageBox.hideMsg();
      });
    },

    /**
     * This is a object that contain two functions to operate prompt ui
     */
    prompt: {
      /**
       * Show prompt word
       */
      show: function() {
        // prompt.style.display = 'block';
      },

      /**
       * hide prompt word
       */      
      hide: function() {
        prompt.style.display = 'none'; 
      }
    },

    /**
     * This is a object that contain two functions to operate prompt ui
     */
    capturedPrompt: {
      /**
       * Show item has been captured prompt 
       */
      show: function() {
        capturedPrompt.style.display = 'block';
      },

      /**
       * Hide item has been captured prompt
       */
      hide: function() {
        capturedPrompt.style.display = 'none';
      }
    },

    /**
     * This is a object that contain three functions to operate login form
     */
    loginForm: {
      /**
       * Add event handler for button
       */
      init: function() {
        //GLOBAL.listener.addDomListener(loginButton, 'click', sap.action.doLogin);
        //GLOBAL.listener.addDomListener(password, 'keypress', sap.action.doLogin);
        //GLOBAL.listener.addDomListener(backButton, 'click', sap.action.doReset);
      },

      /**
       * Show login interface
       */
      show: function() {
        formWrapper.style.display = 'block';
        document.body.style.width = '216px';
      },

      /**
       * Hide login interface
       */
      hide: function() {
        formWrapper.style.display = 'none';
        document.body.style.width = '159px';
      }      
    }
  };
}();

sap.action = {
  /**
   * Call this function when click reset button on login page
   */
  doReset: function() {
    $('#inputs input').each(function() {
        $(this).val('');
    });
    /* sap.communication.postMessage(parent, sap.iframeStatus.cancel);
    sap.UI.loginForm.hide();
    sap.UI.product.hide();
    sap.UI.prompt.show(); */
  },

  /**
   * Send like item  to server
   */
  postData: function(postUrl) {
      var myCommentsTip = sapLang.getText('mycomment');
      console.log(postUrl);
      
      var product = sap.postProduct,
          userAccount = JSON.parse(GLOBAL.storage.getItem('userAccountVO', false)).UserAccountVO;
      accessToken = GLOBAL.storage.getItem('accessToken', false);
      
      var oriPrice=$("#oriPrice").text();
      if(oriPrice != ""){
          oriPrice=parseFloat(oriPrice);
      }
      var promotionPrice=$("#promotionPrice").text();
      if(promotionPrice != ""){
          promotionPrice=parseFloat(promotionPrice);
      }
      
      var itemArr = [],
          typeVal = $("#category").attr('categoryName') || "",
          productIdVal = $("#refNo span.refNo").text(),
          titleVal = $("#title span.title").text().trim() || "",
          styleVal = "",
          commentsVal = ($("#comment textarea").val().trim() == myCommentsTip) ? "" : $("#comment textarea").val().trim(),
          shareOn = "",
          sizesVal = "",
          brand = "";
      
      if($("#style ul.styles li").size()) {
          $("#style ul.styles li").each(function() {
              styleVal += $(this).text() + " ";
          });
      }
      
      var shareToClass = $("#share").attr("class").trim();
      switch(shareToClass) {
          case "weibo-on":
              shareOn = "SINAWEIBO";
              break;
          case "qzone-on":
              shareOn = "QZONE";
              break;
          case "facebook-on":
              shareOn = "FACEBOOK";
              break;
          case "twitter-on":
              shareOn = "TWITTER";
              break;
          default:
              shareOn = "";
              break;
      }
      
      if (product.brand) {
          brand = (product.brandEn) ? product.brandEn : product.brand;
      } else {
          brand = $("#brand").text().trim();
      }
      
      /* if ($("#category").attr('categoryName')) {
          var cate = $("#category").attr('categoryName').split(' ');
          typeVal = cate.length > 1 ? cate[1] : "";
      }*/
      
      if (product.sizes) {
          var sizes = (typeof(product.sizes) == 'string') ? JSON.parse(product.sizes) : product.sizes;
          for (var i = 0; i < sizes.length; i++) {
              sizesVal += sizes[i].trim() + ' ';
          }
      }
      
      $('div.image-highlight').each(function() {
          var item = {
              "shareOn" : shareOn,
              "snsAccount" : "123123123",
              "accessToken" : accessToken,
              "type" : typeVal,
              "property" : {
                  "brand" : {
                    "value" : brand,
                    "dataType" : "String"
                  },
                  "title" : {
                    "value" : titleVal,
                    "dataType" : "String"
                  },
                  "productId" : {
                    "value" : productIdVal,
                    "dataType" : "String"
                  },
                  "styles" : {
                    "value" : styleVal.trim(),
                    "dataType" : "String"
                  },
                  "comments" : {
                    "value" : commentsVal,
                    "dataType" : "String"
                  },
                  "price" : {
                    "value" : oriPrice || promotionPrice,
                    "dataType" : "Number"
                  },
                  "realPrice" : {
                    "value" : oriPrice ? promotionPrice : "",
                    "dataType" : "Number"
                  },
                  "currency" : {
                    "value" : product.currency || "",
                    "dataType" : "String"
                  },
                  "wishCount" : {
                    "value" : 1,
                    "dataType" : "Number"
                  },
                  "sizes" : {
                    "value" : sizesVal.trim(),
                    "dataType" : "String"
                  },
                  "imageId" : {
                    "value" : "",
                    "dataType" : "urlstream"
                  },
                  "color" : {
                    "value" : "",
                    "dataType" : "String"
                  },
                  "colorImageId" : {
                    "value" : "",
                    "dataType" : "urlstream"
                  },
                  "profileId" : {
                    "value" : 123321,
                    "dataType" : "Number"
                  },
                  "profileCity" : {
                    "value" : "SH",
                    "dataType" : "String"
                  },
                  "sourceUrl" : {
                    "value" : product.sourceUrl || "",
                    "dataType" : "String"
                  },
                  "sourceImgUrl" : {
                    "value" : "",
                    "dataType" : "String"
                  },
                  "domain" : {
                    "value" : product.domain || "",
                    "dataType" : "String"
                  },
                  "country" : {
                    "value" : "", //(ZH | EN)
                    "dataType" : "String"
                  },
                  "contributorId" : {
                    "value" : 123321,
                    "dataType" : "Number"
                  },
                  "order" : {
                    "value" : 0,
                    "dataType" : "Number"
                  }
              },
              "publicPermission" : "public",
              "private" : 1,
              "pid" : ""
          },
          
          $this = $(this),
          $imgColor = $this.find('div.image-color').children(),
          imageSrc = $this.find('div.image-div img').attr('src') || "";
          //$cover = $this.find('div.cover');
              
          item.property.imageId.value = imageSrc;
          item.property.sourceImgUrl.value = imageSrc;
          item.property.color.value = $imgColor.attr('title') || '';
          item.property.colorImageId.value = $imgColor.attr('src') || '';
          
          /* if ($cover.css('display') != 'none' && $cover.text() == '取消封面') {
              itemArr.unshift(item);
          } else {
              itemArr.push(item);
          } */
          itemArr.push(item);
      });
      
      var dataStr = JSON.stringify({
          "category" : itemArr
      });
      
      $.ajax({
          type: 'POST',
          url: postUrl,
          //contentType: "application/json; charset=utf-8",
          //headers: { authToken: userAccount.authToken},
	  //headers: {"X-Requested-With": "XMLHttpRequest"},
          data: dataStr,
	  //dataType: 'jsonp',
          success: function(new_response){
	    console.log(new_response);
	    response = JSON.parse(new_response);
            $('#loading').hide();
            $('#submit_picture').removeClass('disabled');
            
            if (response.CondorJSONMsg.Status == "OK") {
                /* myAlert("数据已经传送成功！");*/
                $('#close-btn').removeClass("close-btn-capture-result");
                $("#capture-result").addClass("hidden");
                onWindowResize.remove();
                $("div.content-wrapper").attr("style", "");
                $("#submit-result").removeClass("hidden");
                setTimeout(function() {
                    $("div.content-wrapper").fadeOut(1000, function() {
                        $('#close-btn').click();
                    });
                }, 6000);
            } else {
                sap.messageBox.showMsg(sapLang.getText(response.CondorJSONMsg.Message));
            }
          },
          error: function(XMLHttpRequest, textStatus, errorThrown){
		console.log('error!');
		//console.log(e);
		console.log(textStatus);
		console.log(errorThrown);
          }
      });
  }
////////////////////////////////////////////////////////////////
};

sap.status = {
  /**
   * Check whether user sign in
   */
  isLogin: function() {
    return GLOBAL.storage.getItem('authId', false) ? true : false; 
  },
  
  isSignin: function() {
    if (GLOBAL.storage.getItem('userAccountVO', false)) {
        var expires = GLOBAL.storage.getItem('expires_in', false);
        if (expires && parseInt(expires) > new Date().getTime()) {
          return GLOBAL.storage.getItem('userType', false);
        }
    }
      
    return false; 
  }
};
  
/**
 * ProxyIframe Call this function to capture liked item
 * @param {string} product
 */
sap.capture = function(product) {
  var addNameTip = sapLang.getText('productNameTip'),
      myCommentsTip = sapLang.getText('mycomment');
      
  if (product) {
    function renderImages(imgsInfoArr) {
        var i = 0,
            length = imgsInfoArr.length;
        for (i; i < length; i++) {
            var imageWidth = imgsInfoArr[i].width,
                imageHeight = imgsInfoArr[i].height,
                imageHighlight = '';
                
            //set the first image highlight and show its default color
            if (i == 0) {
                imageHighlight = 'image-highlight';
            }
            
            var imageNodeHtml = '<div class="image-node ' + imageHighlight + '">'
                    + '<div class="image-div">'
                    +   '<img src="' + imgsInfoArr[i].src + '" alt="" title="" />'
                    +   '<span></span>'   //empty inline-block text span, used to set the image node before vertical-align to middle;
                    + '</div>'
                    //+ '<span class="image-size" style="display: none;">' + imageWidth + ' x ' + imageHeight + '</span>'
                    + '<div class="image-color"></div>'
                    //+ '<div class="cover"><span>设为封面</span></div>'
                + '</div>';
            $nodeList.append(imageNodeHtml);
        }
        
        // if there are only one iamge, hide the show-selected-image checkbox and return
        if (length == 1) {
            //$('#checkbox').hide();
            $('div.image-div').first().css('cursor', 'default');
            return;
        }
        
        var $imageDivs = $('div.image-div');
            //$covers = $('div.cover'),
            //$showSelected = $('#checkbox input.show-selected');
            
        // when click on an unselected image, highlight the image and show color list,
        // when click on a selected image, cancel the highlight, reset the set-cover block, and hide the color list
        $imageDivs.each(function() {
            $(this).on('click', function(e) {
                e.stopPropagation();
                $('#color-list').hide();
                
                var $this = $(this),
                    $imageNode = $this.parent(),
                    $imageColor = $imageNode.find('div.image-color'),
                    //$cover = $imageNode.find('div.cover'),
                    color = $imageColor.html();
                
                if ($imageNode.hasClass('image-highlight')) {
                    /* $cover.find('span').text('设为封面');
                    $cover.hide(); */
                    if (color) {
                        $imageColor.hide();
                    }
                    /* if ($showSelected.attr('checked')) {
                        $imageNode.hide();
                    } */
                    
                    $imageNode.removeClass('image-highlight');
                } else {
                    $imageNode.addClass('image-highlight');
                    if(color) {
                        $imageColor.css('display', 'inline-block');
                    }
                    //$this.trigger('mouseenter');
                }
            });
        });
    }
    
    function renderColorList(colorsArr) {
        var colorsLength = colorsArr.length;
        if (colorsLength > 0) {
            var $colorList = $('<div id="color-list"><i class="color-selected-icon"></i><i class="color-list-arrow"></i></div>'),
                $ulHtml = $('<ul></ul>'),
                currentSpanIndex = -1,
                $imgColorDivs = $('div.image-color');
                
            for (var i = 0; i < colorsLength; i++) {
                if (colorsArr[i].src) {
                    $ulHtml.append('<li><img title="' + colorsArr[i].title + '" src="' + colorsArr[i].src + '" /></li>');
                } else {
                    //$ulHtml.append('<li><span title="' + colorsArr[i].title + '">' + colorsArr[i].title + '</span></li>');
                }
            }
            
            if($ulHtml.children().length == 0) {
                return;
            }
            
            // when click each color item in the color list, set the color of the image and hide the color list
            $ulHtml.children().each(function() {
                $(this).on('click', function(e) {
                    e.stopPropagation();
                    var $currentImgColorDiv = $imgColorDivs.eq(currentSpanIndex);
                    
                    $currentImgColorDiv.html($(this).html());
                    $colorList.hide();
                    
                    currentSpanIndex = -1;
                });
            });
            $colorList.append($ulHtml);
            
            $colorList.on("click", function() {
                $imgColorDivs.eq(currentSpanIndex).click();
            });
            $nodeList.append($colorList);
            
            var imageListHeight = 0,
                nodeListHeight = 0,
                colorListHeight = 0;
            // when click the image color area at the bottom of the image, show the the color list
            $imgColorDivs.each(function(index) {
                var $this = $(this);
                
                // set the first color as default
                $this.html($colorList.find('li').first().html());
                if(index == 0) {
                    $this.show();
                }
                
                $this.on('click', function(e) {
                    e.stopPropagation();
                    var $currentImgNode = $(this).parent(),
                        currentImgNodeOffset = $currentImgNode.offset(),
                        imageListOffset = $imageList.offset(),
                        currentImgNodeHeight = $currentImgNode.outerHeight(),
                        nodeListPosition = $nodeList.position();
                    
                    var colorListTop = currentImgNodeOffset.top - imageListOffset.top - nodeListPosition.top + currentImgNodeHeight - $("#color-list i.color-selected-icon").outerHeight() - 2 - 9,  //2: image-color div border width; 9: colorList padding top
                        colorListLeft = currentImgNodeOffset.left - imageListOffset.left + 7;     //7: margin-left;
                    $colorList.css({
                        top: colorListTop + 'px',
                        left: colorListLeft + 'px'
                    }).show();
                    
                    imageListHeight = imageListHeight || $imageList.parent().height();
                    nodeListHeight = nodeListHeight || $nodeList.height();
                    colorListHeight = colorListHeight || $colorList.height();
                    if((nodeListHeight - IMG_LIST_MARGIN_TOP * 2 + colorListHeight - 32) > imageListHeight && (colorListTop + 32) >= (nodeListHeight - IMG_LIST_MARGIN_TOP * 2) && $scrollbar.css('display') == "none") {
                        $scrollbar.show();
                    }
                    
                    currentSpanIndex = index;
                });
            });
            
            $('body').on('click', function() {
                $colorList.hide();
            });
        }
    }
    
    function renderInfoList(relation) {
        for (var item in relation) {
            if (product[item]) {
                switch (item) {
                    case 'currency':
                        currency = product['currency'];
                        break;
                    case 'name':
                        var name = product[item].trim();
                        $('#' + relation[item] + " span").text(name).attr('title', name);
                        $('#' + relation[item] + " input").val(name);
                        $('#' + relation[item]).removeClass('title-edit');
                        
                        iLike.category.productName = name;
                        if (iLike.category.categories && 0 == $("#tag_view").length) {
                            iLike.category.fillCateByName(name);
                        }
                        break;
                    case 'oriPrice':
                    case 'promotionPrice':
                        priceArr.push(product[item].replace(/[, ，]/, ''));
                        break;
                    case 'imgsInfo':
                        imgsInfoArr = (typeof(product['imgsInfo']) == 'string') ? JSON.parse(product['imgsInfo']) : product['imgsInfo'];
                        break;
                    case 'colors':
                        colorsArr = (typeof(product['colors']) == 'string') ? JSON.parse(product['colors']) : product['colors'];
                        break;
                    case 'refNo':
                        $('#' + relation[item] + " span.refNo").text(product[item].trim()).parent().removeClass('hidden');
                        break;
                    default:
                        var valStr = (typeof(product[item]) != 'string') ? product[item].join(' ') : product[item];
                        $('#' + relation[item]).text(valStr.trim());
                        break;
                }
            }
        }
        
        var $title = $("#title"),
            $titleInput = $("#title input.title"),
            $editIcon = $("#title i.edit-icon"),
            $titleSpan = $("#title span.title");
        
        $titleInput.on("focus", function() {
            var $this = $(this);
            if($this.val().trim() == addNameTip) {
                $this.val("");
            }
        }).on("blur", function() {
            var $this = $(this);
            if($this.val().trim() == "" || $this.val().trim() == addNameTip) {
                $this.val(addNameTip);
                $titleSpan.text("").attr("title", "");
            }else {
                $title.removeClass("title-edit");
                $titleSpan.text($this.val().trim()).attr("title", $this.val().trim());
            }
        }).on('keypress', function(e) {
            e.stopPropagation();
            if(e.keyCode == 13) {
                e.preventDefault();
                $(this).blur();
            }
        });
        
        $editIcon.on("click", function() {
            $title.addClass("title-edit");
            $titleInput.focus();
        });
        
        var $commentTextarea = $("#comment textarea");
        $commentTextarea.on("focus", function() {
            var $this = $(this);
            if($this.val().trim() == myCommentsTip) {
                $this.val("");
            }
        }).on("blur", function() {
            var $this = $(this);
            if($this.val().trim() == "" || $this.val().trim() == myCommentsTip) {
                $this.val(myCommentsTip);
            }
        });
        
        var $shareCheckbox = $("#share i.checkbox-icon");
        $shareCheckbox.on("click", function() {
            var $this = $(this).parent();
            if($this.hasClass("weibo-on")) {
                $this.removeClass("weibo-on").addClass("weibo-off");
            }else if($this.hasClass("weibo-off")) {
                $this.removeClass("weibo-off").addClass("weibo-on");
            }else if($this.hasClass("qzone-on")) {
                $this.removeClass("qzone-on").addClass("qzone-off");
            }else if($this.hasClass("qzone-off")) {
                $this.removeClass("qzone-off").addClass("qzone-on");
            }else if($this.hasClass("facebook-on")) {
                $this.removeClass("facebook-on").addClass("facebook-off");
            }else if($this.hasClass("facebook-off")) {
                $this.removeClass("facebook-off").addClass("facebook-on");
            }else if($this.hasClass("twitter-on")) {
                $this.removeClass("twitter-on").addClass("twitter-off");
            }else if($this.hasClass("twitter-off")) {
                $this.removeClass("twitter-off").addClass("twitter-on");
            }
        });
        
        var $oriPrice = $('#oriPrice'),
            $promotionPrice = $('#promotionPrice');
        
        if ((2 == priceArr.length) && (priceArr[0] != priceArr[1])) {
            var smallPrice, bigPrice;
            if (parseFloat(priceArr[0]) > parseFloat(priceArr[1])) {
                bigPrice = priceArr[0];
                smallPrice = priceArr[1];
            } else {
                smallPrice = priceArr[0];
                bigPrice = priceArr[1];
            }
            $oriPrice.text(bigPrice + ' ' + currency);
            $promotionPrice.text(smallPrice + ' ' + currency);
        } else if (0 == priceArr.length) {
            $('#price-row').hide();
        } else {
            $oriPrice.hide();
            $promotionPrice.text(priceArr[0] + ' ' + currency).addClass("promotionAsOrigin");
        }
    }
    
    var itemRelation = {
            brand: 'brand',
            currency: 'currency',
            name: 'title',
            oriPrice: 'oriPrice',
            promotionPrice: 'promotionPrice',
            refNo: 'refNo',
            imgsInfo: 'imgsInfo',
            colors: 'colors',
            sizes: 'size'
        },
        currency = '',
        priceArr = [],
        imgsInfoArr = [],
        colorsArr = [];
    
    var $backgroundWrapper = $('div.background-wrapper'),
        //$logo = $('#logo'),
        //$checkbox = $('#checkbox'),
        $contentWrapper = $('div.content-wrapper'),
        //$infoList = $('#info-list'),
        $imageList = $('#image-list div.image-list'),
        $nodeList = $('div.node-list'),
        $scrollbar = $('div.scrollbar'),
        $bar = $('div.bar'),
        $cateInputNode = $('#category'),
        $tagInputNode = $('#style');
    
    var IMG_HEIGHT = 142,
        IMG_NODE_HEIGHT = IMG_NODE_WIDTH =158,
        IMG_NODE_MARGIN = 6,
        LEFT_CONTENT_PADDING_LEFT = 40,
        LEFT_CONTENT_PADDING_RIGHT = 20,
        LEFT_CONTENT_PADDING_TOP = LEFT_CONTENT_PADDING_BOTTOM = 30,
        IMG_LIST_MARGIN_TOP = 7,
        IMG_LIST_MARGIN_LEFT = -13,
        WIDTH_BETWEEN_NODELIST_SCROLLBAR = 14,
        IMG_LIST_SCROLLBAR_OUTER_WIDTH = 10,
        IMG_LIST_WIDTH_INIT = 360,
        LEFT_CONTENT_WIDTH_INIT = RIGHT_CONTENT_WIDTH = 420,
        CONTENT_WRAPPER_HEIGHT = 600,
        imageListHeight = 0;
    
    renderInfoList(itemRelation);
    renderImages(imgsInfoArr);
    renderColorList(colorsArr);
    
    function renderContentWrapper(row, colum) {
        if (row) {
            if(row != 2) {
                initImgListHeight();
            }
        }
        
        if (colum) {
            if(colum > 2) {
                var nodeListWidth = (IMG_NODE_WIDTH + IMG_NODE_MARGIN) * colum,
                imageListWidth = nodeListWidth + WIDTH_BETWEEN_NODELIST_SCROLLBAR,
                leftContentWidth = imageListWidth + LEFT_CONTENT_PADDING_LEFT + LEFT_CONTENT_PADDING_RIGHT + 15,
                contentWrapperWidth = leftContentWidth + RIGHT_CONTENT_WIDTH;
                
                $nodeList.width(nodeListWidth);            
                $imageList.width(imageListWidth);
                $imageList.parent().width(leftContentWidth - (LEFT_CONTENT_PADDING_LEFT + IMG_LIST_MARGIN_LEFT));
                $contentWrapper.width(contentWrapperWidth);
            }else {
                $nodeList.width(IMG_LIST_WIDTH_INIT - WIDTH_BETWEEN_NODELIST_SCROLLBAR - IMG_LIST_SCROLLBAR_OUTER_WIDTH -  - IMG_NODE_MARGIN);
                $imageList.width(IMG_LIST_WIDTH_INIT - IMG_LIST_SCROLLBAR_OUTER_WIDTH - IMG_NODE_MARGIN);
                $imageList.parent().width(LEFT_CONTENT_WIDTH_INIT - (LEFT_CONTENT_PADDING_LEFT + IMG_LIST_MARGIN_LEFT));
                $contentWrapper.width(LEFT_CONTENT_WIDTH_INIT + RIGHT_CONTENT_WIDTH);
            }
        }
    }
    
    function resizeContent() {
        if($("#color-list").css('display') != 'none') {
            $("#color-list").hide();
        }
        
        var bgWidth = $backgroundWrapper.width(),
            length = imgsInfoArr.length,
            maxRow = 2,
            maxColum = getMaxColum(bgWidth);
        
        if (length <= maxColum*maxRow) {
            var colum = Math.floor((length + 1) / 2);
            renderContentWrapper(maxRow, colum);
        } else {
            renderContentWrapper(maxRow, maxColum);
        }
        
        sap.scrollbar.resizeScrollbar();
    }
    
    function getMaxColum(bgWidth) {
        var colum = Math.floor((bgWidth - RIGHT_CONTENT_WIDTH - (LEFT_CONTENT_PADDING_LEFT + LEFT_CONTENT_PADDING_RIGHT) - IMG_NODE_MARGIN - IMG_LIST_SCROLLBAR_OUTER_WIDTH) / (IMG_NODE_WIDTH + IMG_NODE_MARGIN));
        if (colum > 5) {
            colum = 5;
        } else if (colum < 1) {
            colum = 1;
        }
        return colum;
    }
    
    function initImgListHeight() {
        var originInfoHeight = $("#origin-info").outerHeight(),
            uploadTipHeight = $("span.upload-tip").outerHeight(),
            imageListHeight = imageListHeight || CONTENT_WRAPPER_HEIGHT - (LEFT_CONTENT_PADDING_TOP + LEFT_CONTENT_PADDING_BOTTOM) - originInfoHeight - uploadTipHeight - IMG_LIST_MARGIN_TOP;
                    
            $imageList.parent().height(imageListHeight);
    }
    
    resizeContent();
    onWindowResize.add(resizeContent);
    //window.onresize = resizeContent;
  }
};

sap.scrollbar = {
    $imageList: $("div.image-list"),
    $nodeList: $("div.node-list"),
    $scrollbar: $("div.scrollbar"),
    $bar: $("div.scrollbar div.bar"),
    nodeListInitTop: -6,
    imageNodePadding: 7,
    imageNodeMargin: 6,
    imageDivBorder: 1,
    imageListHeight: 0,
    scrollbarHeight: 0,
    colorListExpandingHeight: 0,
    
    resizeScrollbar: function() {
        var nodeListHeight = this.$nodeList.height(),
            scrollbarHeight = this.scrollbarHeight || this.$imageList.parent().height();
            
        if(nodeListHeight > scrollbarHeight) {
            var barHeight = scrollbarHeight * scrollbarHeight / (nodeListHeight + this.colorListExpandingHeight);
            
            this.updateNodelist(scrollbarHeight, barHeight);
            this.updateScrollbar(nodeListHeight, scrollbarHeight, barHeight);
            
            if(this.$scrollbar.css("display") == "none") {
                this.$scrollbar.show();
            }
        }else {
            if(this.$scrollbar.css("display") != "none") {
                this.$scrollbar.hide();
            }
        }
    },
    
    updateScrollbar: function(nodeListHeight, scrollbarHeight, barHeight) {
        var nodeListTop = - (this.$nodeList.position().top - this.nodeListInitTop),
            maxNodeListTop = nodeListHeight + this.colorListExpandingHeight - (this.imageListHeight || this.$imageList.parent().height()) - this.imageNodePadding * 2 - this.imageNodeMargin + this.imageDivBorder * 2,
            rate = nodeListTop / maxNodeListTop,
            maxScrollbarTop = scrollbarHeight - barHeight,
            barTop = maxScrollbarTop * rate;
        
        this.$bar.height(barHeight);
        this.$bar.css("top", barTop + "px");
    },
    
    updateNodelist: function(scrollbarHeight, barHeight, barTop) {
        var nodeListTop = this.$nodeList.position().top,
            nodeListHeight = this.$nodeList.height(),
            imageListHeight = this.imageListHeight || this.$imageList.parent().height(),
            maxNodeListTop = - (nodeListHeight + this.colorListExpandingHeight - imageListHeight - this.imageNodePadding * 2 - this.imageNodeMargin + this.imageDivBorder * 2);
        
        if(typeof(barTop) != "undefined") {
            var maxScrollbarTop = scrollbarHeight - barHeight,
                rate = barTop / maxScrollbarTop;
                
            nodeListTop = maxNodeListTop * rate + this.nodeListInitTop;
            this.$nodeList.css("top", nodeListTop + "px");
        }else {
            if(nodeListTop < maxNodeListTop + this.nodeListInitTop) {
                nodeListTop = maxNodeListTop + this.nodeListInitTop;
                this.$nodeList.css("top", nodeListTop + "px");
            }
        }
    },
    
    init: function() {
        var self = this;
        var isMouseDown = false;
        var offsetY = 0,
            barPositionTop = 0;
        var imageListHeight = self.$imageList.parent().height(),
            nodeListHeight = self.$nodeList.outerHeight(),
            scrollbarHeight = self.scrollbarHeight || imageListHeight;
            
        if($("#color-list").outerHeight()) {
            self.colorListExpandingHeight = $("#color-list").outerHeight() - 32;
        }
        
        self.$bar.height(imageListHeight * scrollbarHeight / (nodeListHeight + self.colorListExpandingHeight));
        if(nodeListHeight > imageListHeight) {
            self.$scrollbar.show();
        }else {
            if(self.$scrollbar.css("display") != "none") {
                self.$scrollbar.hide();
            }
        }
        
        self.$bar.mousedown(function(e) {
            var event = window.event || e; //获取事件对象
            if(event.button != 2 && event.button != 3) {
                isMouseDown = true;
                offsetY = event.clientY;
                barPositionTop = $(this).position().top;
            }
        });
        
        self.$imageList.parent().mousemove(function(e) {
            var event = window.event || e; //获取事件对象
            if(isMouseDown) {
                var y = event.clientY - offsetY,
                    barTop = barPositionTop + y,
                    barHeight = self.$bar.height(),
                    maxBarTop = scrollbarHeight - barHeight;
                    
                if(barTop > maxBarTop) {
                    barTop = maxBarTop;
                }else if(barTop < 0) {
                    barTop = 0;
                }
                
                self.$bar.css("top", barTop + "px");
                
                self.updateNodelist(scrollbarHeight, barHeight, barTop);
                
                event.cancelBubble = true;
                event.returnValue = false; 
                return false;
            }
        });
        
        $(document).mouseup(function() {
            isMouseDown = false;
        });
        
        sap.mousewheel.init(self.$imageList.parent(), self.$scrollbar, self.$nodeList, self.colorListExpandingHeight);
    }
};

sap.mousewheel = {
    wheelArea: null,
    
    scrollBar: null,
    bar: null,
    nodeList: null,
    
    wheelStep: 10,
    barMaxTop: 0,
    barMinTop: 0,
    nodeListMaxTop: -6,
    nodeListMinTop: 0,
    colorListExpandingHeight: 0,
        
    addEvent: function(obj, type, callback, useCapture) {
        if(obj.dispatchEvent){
            obj.addEventListener(type, callback, !!useCapture);
        }else {
            obj.attachEvent("on" + type, callback);
        }
        return callback;//返回callback方便卸载时用
    },
    
    init: function($wheelArea, $scrollBar, $nodeList, colorListExpandingHeight){
        var self = this;
        self.wheelArea = $wheelArea[0];
        self.scrollBar = $scrollBar[0];
        $bar = $scrollBar.find("div.bar");
        self.bar = $bar[0];
        self.nodeList = $nodeList[0];
        self.colorListExpandingHeight = colorListExpandingHeight;
        
        var wheelType = "mousewheel";
        try{
            document.createEvent("MouseScrollEvents");
            wheelType = "DOMMouseScroll";
        }catch(e){
            //to do nothing
        }
        
        self.addEvent(self.wheelArea, wheelType, function(event) {
            if ("wheelDelta" in event){//统一为±120，其中正数表示为向上滚动，负数表示向下滚动
                var delta = event.wheelDelta;
                //opera 9x系列的滚动方向与IE保持一致，10后修正
                if(window.opera && opera.version() < 10) {
                    delta = - delta;
                }
                //由于事件对象的原有属性是只读，我们只能通过添加一个私有属性delta来解决兼容问题
                event.delta = Math.round(delta) / 120; //修正safari的浮点 bug
            }else if("detail" in event){
                event.wheelDelta = - event.detail * 40; //为FF添加更大众化的wheelDelta
                event.delta = event.wheelDelta / 120; //添加私有的delta
            }
            
            if(event.preventDefault) {
                event.preventDefault();
            }else {
                event.returnValue = false;
            }
            
            self.updateImageList(event);
        });
    },
    
    getCurrentTop: function(now, max, min) {
        return Math.min(max, Math.max(now, min));
    },
    
    updateImageList: function(event) {
        var self = this;
        if(self.scrollBar.style.display == "" || self.scrollBar.style.display == "none") {
            return;
        }
        self.barMaxTop = self.scrollBar.clientHeight - self.bar.clientHeight;
        self.bar.style.top = self.getCurrentTop(self.bar.offsetTop + (- 1 * event.delta * self.wheelStep), self.barMaxTop, self.barMinTop) + 'px';
        
        self.nodeListMinTop = - (self.nodeList.clientHeight + self.colorListExpandingHeight - self.wheelArea.clientHeight - 7 * 2 + 1 * 2);
        nodeListNowTop = self.nodeList.offsetTop + event.delta * (self.wheelStep / (self.barMaxTop - self.barMinTop) * (self.nodeListMaxTop - self.nodeListMinTop));
        self.nodeList.style.top = self.getCurrentTop(nodeListNowTop, self.nodeListMaxTop, self.nodeListMinTop) + 'px';
    }
};

sap.messageBox = {
    $messageSpan : $('#sys-message-box span.message'),
    
    showMsg : function(msg) {
        if (msg) {
            this.$messageSpan.text(msg).parent().show();
        }else {
            this.hideMsg();
        }
    },
    
    hideMsg : function() {
        this.$messageSpan.text("").parent().hide();
    }
};


/**
 * apis to call for ajax
 */
sap.api = {};

/**
 * Get api's directory.
 */
var urlPrefix = function() {
  var reg = /\/[\w-]+\/[a-zA-Z]+\.html.*/;
  return (document.URL).replace(reg, '');
}();
