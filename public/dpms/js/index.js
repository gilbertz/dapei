$(document).ready(function () {
  if (SJBindex.host.indexOf('localhost') != -1) {
    SJBindex.host = 'www.dapeimishu.com:9090';
  }
  SJBindex.setBaseSize();
  $(window).resize(function() {
    SJBindex.setBaseSize();
  });

  $('.channel-link').click(function() {
    SJBindex.goToChannel($(this).attr('id'));
  });
  SJBindex.getUserInfo();
  SJBindex.goToChannel('arrange');
  var t = setInterval(function() { // 在ajax请求中为防止重复发送请求，增加了状态量Ajaxstate，如果等于1表示可以发送请求，否则不可以，这段逻辑可以在请求出错时，改变请求状态。
    ajaxState = 1;
  },5000);
});

var SJBindex = {
  user: {
  },
  z: 1,
  host: location.host,
  protocol: location.protocol,
  prompt: function(text) {
    var thePrompt = $('.templates .prompt').clone();
    thePrompt.children('.prompt-text').text(text);  
    thePrompt.appendTo('body').fadeIn(200).delay(500).fadeOut(200, function() {
      $(this).remove();
    });
  },
  loginCallback: function(data) {
    var mineItem = $('.mine-channel').find('.login');
    if (data.error) {
      SJBindex.prompt(data.error);
    } else {
      if (data.user) {
        data.session = data.user;
        this.z++; // 由getUserInfo回调该函数，执行backPrev会多减z；
      }
      $.extend(true, SJBindex.user, data.session);
      mineItem.find('.mine-item-logo').attr('src', data.session.avatar_img_medium);
      mineItem.find('.text').text(data.session.display_name);
      mineItem.attr('onclick', 'SJBindex.pushNewPage(SJBindex.homePage.createPage("'+ data.session.user_id +'"))');
      $('.logout').show();
      SJBindex.backPrev.call($('.login-page:not(.template)').find('.icon.header-left-icon'));
    }
  },
  getUserInfo: function() {
    if ($.cookie('userid')) {
      $.ajax({
        url: SJBindex.protocol + '//' + SJBindex.host + '/users/' + $.cookie('userid') + '.json',
        dataType: 'JSON',
        cache: false,
        success: function(data) {
          SJBindex.loginCallback(data);
        }
      });
    }
  },
  checkLogin: function() {
    if (!$.cookie('userid')) {
      this.prompt('尚未登录');
      this.pushNewPage(this.loginPage.createPage());
      return false;
    } else {
      return true;
    }
  },
  loginFn: function() {
    var username = $('.login-page #une').val();
    var password = $('.login-page #pwd').val();
    $.ajax({
      url: SJBindex.protocol + '//' + SJBindex.host + '/accounts/info/sign_in.json',
      type: 'post',
      data: {
        user: {
          email: username,
          password: password
        }
      },
      dataType: 'JSON',
      success: function(data) {
        SJBindex.loginCallback(data);
      },
      error: function() {
        SJBindex.prompt('用户名或密码错误');
      }
    });
  },
  logoutFn: function() {
    // $.cookie('userid', '', 'l', '', {'expires': -1, 'path': '/'});
    // location.reload();
  },
  homePage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '主页',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    createPage: function(userid) {
      var thisPage = $('.page.home-page').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      $.ajax({
        url: SJBindex.protocol + '//' + SJBindex.host + '/users/' + userid + '.json?token='+ SJBindex.user.token,
        data: {
          like: 0,
          page: 1
        },
        dataType: 'JSON',
        success: function(data) {
          thisPage.find('.home-bg').css({
            'background': 'url('+ data.user.bg_img +')',
            'background-size': 'cover'
          }),
          thisPage.find('.home-avatar>img').attr({
            'src': data.user.avatar_img_small,
            'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + data.user.user_id + '"))'
          }),
          thisPage.find('.home-username').text(data.user.name);
          thisPage.find('.home-user-desc').text(data.user.desc);
          thisPage.find('.home-following').text('关注 ' + data.user.following_count);
          thisPage.find('.home-follower').text('粉丝 ' + data.user.followers_count);
          thisPage.find('.home-pub-count').html('发布<span class="home-count">' + data.user.dapei_count + '</span>个搭配');
          thisPage.find('.home-like-count').html('收到<span class="home-count">' + data.user.dapei_likes_count + '</span>个喜欢');
          if (data.user.is_following === "0" || !data.user.is_following) {
            thisPage.find('.home-attention').attr({
              'onclick': 'SJBindex.follow("'+ data.user.user_id +'", this)'
            });
          } else if (data.user.is_following === "1") {
            thisPage.find('.home-attention').css({
              'background': '#ddd',
              'color': '#222'
            }).attr({
              'onclick': 'SJBindex.follow("' + data.user.user_id + '", this, true)'
            }).text('取消关注');
          }
          if (data.user.user_id == SJBindex.user.user_id) {
            thisPage.find('.home-attention').remove();
          }
        }
      });
      return thisPage;
    },
  },
  
  channelInfo: {
    arrange: {
      id: 'arrange',
      loadState: 0,
      nextPage: 1, // 对于可以滚动加载的列表有这个变量，表示将要加载的页码
      header: {
        pendEle: function() {
          return $('.arrange-channel');
        },
        left: {
          icon: '',
          clickFn: undefined
        },
        title: '搭配秀',
        right: {
          icon: '',
          clickFn: undefined
        }
      },
      loadFn: function() {
        // this.createBanner();
        this.addNewItem();
        SJBindex.scrollLoad($('.' + this.id + '-channel'), SJBindex.channelInfo[this.id]);
        SJBindex.setHeader(this.header);
      },
      createBanner: function() {
        var bannerImgCount;
        var banner = document.getElementById('banner');
        var $bannerImgContainer = $('#banner-img-container');
        $.ajax({
          url: '/info/app_banner_new.json',
          dataType: 'JSON',
          cache: false,
          async: false,
          data: {
            like: 0,
            page: 1
          },
          success: function(data) {
            bannerImgCount = data.records.length;
            $bannerImgContainer.width(SJBenvironment.windowW * bannerImgCount);
            for (var i = 0; i < bannerImgCount; i++) {
              $bannerImgContainer.append('<a href="#"><img class="banner-img" width="' + SJBenvironment.windowW + '" src="' + data.records[i].img_url + '"></a>');
            }
          }
        });
        $bannerImgContainer.append('<ul class="clear"></ul>');
        slip('page', $bannerImgContainer[0], {
          num: bannerImgCount,
          change_time: 4000
        });
      },
      itemClickFn: function(dapeiId) {
        SJBindex.pushNewPage(SJBindex.arrangeDetail.createPage(dapeiId));
      },
      addNewItem: function() {
        var that = this;
        ajaxState = 0;
        $.ajax({
          url: SJBindex.protocol + '//' + SJBindex.host + '/dapeis/index_all.json?token='+ SJBindex.user.token ,
          dataType: 'JSON',
          cache: false,
          data: {
            page: that.nextPage,
            like: 0
          },
          success: function(data) {
            var nextItem;
            ajaxState = 1;
            SJBdataCache.dapeis = SJBdataCache.dapeis || {};
            for (var i = 0; i < data.dapeis.length; i++) {
              data.dapeis[i].like_id = Number(data.dapeis[i].like_id);
              nextItem = $('.templates>.arrange-item').clone();
              nextItem.find('.arrange-item-like-heart>img').attr({
                'onclick': 'SJBindex.like("Item", "' + data.dapeis[i].dapei_id + '", this)'
              });
              if (data.dapeis[i].like_id) {
                nextItem.find('.arrange-item-like-heart>img').attr({
                  'src': 'images/icons/liked.png',
                  'onclick': 'SJBindex.like("Item", "' + data.dapeis[i].dapei_id + '", this, true)'
                });
              }
              nextItem.find('.arrange-item-img>img').attr({
                'src': data.dapeis[i].img_urls_large[0].img_url,
                'dapei_id': data.dapeis[i].dapei_id
              }).click(function(i) {
                var reali = i;
                return function() {
                  that.itemClickFn(data.dapeis[reali].dapei_id);
                }
              }(i));
              nextItem.find('.arrange-item-avatar>img').attr({
                'src': data.dapeis[i].user.avatar_img_small,
                'userid': data.dapeis[i].user.user_id,
                'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + data.dapeis[i].user.user_id + '"))'
              });
              nextItem.find('.arrange-item-name').text(data.dapeis[i].user.name);
              nextItem.find('.arrange-item-like-count').text(data.dapeis[i].likes_count);
              nextItem.appendTo($('.arrange-channel>.list'));
              SJBdataCache.dapeis[data.dapeis[i].dapei_id] = data.dapeis[i]; // 保存返回的搭配数据
            }
            that.nextPage++;
          }
        })
      },
    },
    single: {
      id: 'single',
      loadState: 0,
      nextPage: 1,
      header: {
        pendEle: function() {
          return $('.single-channel');
        },
        left: {
          icon: null,
          clickFn: undefined
        },
        title: '单品',
        right: {
          icon: '',
          clickFn: undefined
        }
      },
      colHeight: [0, 0],
      loadFn: function() {
        this.addNewItem();
        SJBindex.scrollLoad($('.' + this.id + '-channel'), SJBindex.channelInfo[this.id]);
        SJBindex.setHeader(this.header);
      },
      itemClickFn: function(singleId) {
        SJBindex.pushNewPage(SJBindex.singleDetail.createPage(singleId));
      },
      addNewItem: function() {
        var that = this;
        ajaxState = 0;
        $.ajax({
          url: SJBindex.protocol + '//' + SJBindex.host + '/matters.json',
          data: {
            page: that.nextPage,
            like: 0
          },
          dataType: 'JSON',
          cache: false,
          success: function(data) {
            ajaxState = 1;
            SJBdataCache.singles = SJBdataCache.singles || {};
            var nextItem, whichCol;
            for (var i = 0; i < data.matters.length; i++) {
              nextItem = $('.templates>.single-item').clone();
              nextItem.children('img').attr({
                'src': data.matters[i].img_url,
                'min-height': '3rem',
                'single_id': data.matters[i].object_id
              }).click(function(i) {
                var reali = i;
                return function() {
                  that.itemClickFn(data.matters[reali].object_id);
                }
              }(i));
              nextItem.find('.single-item-brand cut').text(data.matters[i].brand_name);
              nextItem.find('.single-item-price').text(data.matters[i].price);
              whichCol = that.colHeight[0] < that.colHeight[1] ? 0 : 1;
              that.colHeight[whichCol] += Number(data.matters[i].h);
              nextItem.appendTo($('.single-channel>.list').children().eq(whichCol));
              SJBdataCache.singles[data.matters[i].object_id] = data.matters[i];
            }
            that.nextPage++;
          }
        });
      }
    },
    find: {
      id: 'find',
      loadState: 0,
      header: {
        pendEle: function() {
          return $('.find-channel');
        },
        left: {
          icon: null,
          clickFn: undefined
        },
        title: '找感兴趣的人',
        right: {
          icon: '',
          clickFn: undefined
        }
      },
      loadFn: function() {
        SJBindex.setHeader(this.header);
        this.addNewItem();
        SJBindex.scrollLoad($('.find-channel'), SJBindex.channelInfo.find);
      },
      createPage: function() {

      },
      nextPage: 1,
      type: 'load', // 这个type有两个值可取，'load'：表示加载之后推荐的，'search'表示的是通过搜索得到的，两中type会对应不同的api url；
      addNewItem: function() {
        var url;
        var that = this;
        ajaxState = 0;
        if (this.nextPage == 1) {
          $('.find-channel .intrest-item.template').siblings().remove();
        }
        if (this.type == 'load') {
          url = SJBindex.protocol + '//' + SJBindex.host + '/users/info/recommended.json';
        } else if (this.type == 'search') {
          url = SJBindex.protocol + '//' + SJBindex.host + '/info/search.json?index=user';
        }
        $.ajax({
          url: url,
          data: {
            page: this.nextPage,
            token: SJBindex.user.token,
            q: $('.search-input').val()
          },
          dataType: 'JSON',
          success: function(data) {
            that.nextPage++;
            ajaxState = 1;
            var thisPage = $('.find-channel');
            var list = thisPage.find('.list');
            var intrests = data.users || [];
            for (var i = 0; i < intrests.length; i++) {
              $theIntrest = thisPage.find('.intrest-item.template').clone().removeClass('template');
              $theIntrest.find('.intrest-avatar').children('img').attr({
                'src': intrests[i].avatar_img_small,
                'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + intrests[i].user_id + '"))'
              });
              $theIntrest.find('.intrest-user-name').text(intrests[i].display_name);
              $theIntrest.find('.intrest-content').text('发布' + intrests[i].dapei_count + '个搭配 粉丝：' + intrests[i].followers_count + '个');
              if (intrests[i].is_following === "0") {
                $theIntrest.find('.attention').attr({
                  'onclick': 'SJBindex.follow("'+ intrests[i].user_id +'", this)'
                });
              } else if (intrests[i].is_following === "1") {
                $theIntrest.find('.attention').css({
                  'background': '#ddd',
                  'color': '#222'
                }).attr({
                  'onclick': 'SJBindex.follow("' + intrests[i].user_id + '", this, true)'
                }).text('取消关注');
              }
              $theIntrest.appendTo(list);
            }
          }
        });
      },
      search: function(that) {
        this.type = 'search';
        this.nextPage = 1;
        this.addNewItem();
      },
      cancel: function(that) {
        $(that).hide();
        $(that).siblings('.search-btn').show();
        this.type = 'load';
        this.nextPage = 1;
        this.addNewItem();
      },
      changeToCancel: function(that) {
        if ($('.search-input').val() == '') {
          $(that).siblings('.search-btn').hide();
          $(that).siblings('.cancel-btn').show();
        }
      }
    },
    mine: {
      id: 'mine',
      loadState: 0,
      header: {
        pendEle: function() {
          return $('.mine-channel');
        },
        left: {
          icon: null,
          clickFn: undefined
        },
        title: '我的',
        right: {
          icon: '',
          clickFn: undefined
        }
      },
      loadFn: function() {
        SJBindex.setHeader(this.header);
        var appRecommendList = $('.app-recommend-list');
        $.ajax({
          url: '/brand_admin/apps.json?' + SJBenvironment.OS + '=&token='+ SJBindex.user.token,
          dataType: 'JSON',
          data: {
            like: 0,
            page: 1
          },
          success: function(data) {
            for (var i = data.apps.length - 1; i >= 0; i--) {
              var appRecommendItem = $('.app-recommend-item.template').clone().removeClass('template');
              appRecommendItem.find('.app-name').text(data.apps[i].dev_name);
              appRecommendItem.find('.app-icon').attr('src', data.apps[i].icon_url);
              appRecommendItem.attr('href', data.apps[i].click_url);
              appRecommendItem.prependTo(appRecommendList);
            }
          }
        })
      }
    }
  },

  arrangeDetail: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '搭配详情',
      right: {
        icon: '',
        clickFn: undefined
      }
    },
    createPage: function(dapeiId) {
      $.ajax({
        url: SJBindex.protocol + '//' + SJBindex.host + '/dapeis/get_dp_items/' + dapeiId + '.json?token=' + SJBindex.user.token,
        dataType: 'JSON',
        data: {
          like: 0,
          page: 1
        },
        success: function(data) {
          var tdStr;
          for (var i = 0; i < 6; i++) {
            if (i < data.matters.length) {
              tdStr = '<td>'+
              '<div class="item-img" style="background: url(' + data.matters[i].small_jpg + ') center center no-repeat; background-size: contain;"></div>'+
              '<div class="item-brand">' + data.matters[i].brand_name + '</div></td>';
            } else {
              tdStr = '<td></td>'
            }
            !(i % 3) &&  $('.page.arrange-detail.current-page table').append('<tr></tr>');
            $('.page.arrange-detail.current-page').find('tr:last').append(tdStr);
          }
        }
      });
      $.ajax({
        url: SJBindex.protocol + '//' + SJBindex.host + '/dapeis/'+ dapeiId +'/get_dapei_detail.Json?token='+ dapeiId,
        dataType: 'JSON',
        data: {
          like: 0,
          page: 1
        },
        success: function(data) {
          var likes = data.dapei.likes || [];
          var comments = data.dapei.comments || [];
          var likesCount = Math.min(likes.length, 6);
          var commentsCount = Math.min(comments.length, 3);
          var $theLike;
          thisPage.find('.like-count').text(likes.length);
          thisPage.find('.comment-count').text(comments.length);
          for (var i = likesCount - 1; i >= 0; i--) {
            $theLike = thisPage.find('.a-d-c-avatar.template').clone().removeClass('template');
            $theLike.children('img').attr({
              'src': likes[i].avatar_img_small,
              'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + likes[i].user_id + '"))'
            });
            $theLike.prependTo(thisPage.find('.likes-user'));
          }
          if (6 < likes.length) {
            thisPage.find('.more-like-btn').show().attr('onclick', 'SJBindex.pushNewPage(SJBindex.moreLikePage.createPage("' + data.dapei.dapei_id + '", null))');
          }
          for (var i = 0; i < commentsCount; i++) {
            $theComment = thisPage.find('.comment-item.template').clone().removeClass('template');
            $theComment.find('.comment-avatar').children('img').attr({
              'src': comments[i].user.avatar_img_small,
              'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + comments[i].user_id + '"))'
            });
            $theComment.find('.comment-user-name').text(comments[i].user.display_name);
            $theComment.find('.comment-date').text(comments[i].created_at.slice(0, 11));
            $theComment.find('.comment-content').text(comments[i].comment);
            $theComment.appendTo(thisPage.find('.comments-detail'));
          }
          thisPage.find('.more-comments-btn').attr('onclick', 'SJBindex.pushNewPage(SJBindex.moreCommentPage.createPage("'+ dapeiId +'", null))');
          if (3 < comments.length) {
            thisPage.find('.more-comments-btn').show();
          }
        }
      });
      var mainImgData = SJBdataCache.dapeis[dapeiId];
      var thisPage = $('.page.arrange-detail.page-template').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      thisPage.find('.arrange-title').text(mainImgData.title)
      thisPage.find('.arrange-update').text(mainImgData.updated_at.slice(0, 11));
      thisPage.find('.main-img>img').attr('src', mainImgData.img_urls_large[0].img_url);
      thisPage.find('.username').text(mainImgData.user.name);
      thisPage.find('.desc').text(mainImgData.user.desc);
      thisPage.find('.avatar>img').attr({
        'src': mainImgData.user.avatar_img_small,
        'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + mainImgData.user.user_id + '"))'
      });
      thisPage.find('.bottom-bar .left-icon img').attr({
        'onclick': 'SJBindex.showComment("' + dapeiId + '", "Item")'
      });
      thisPage.find('.bottom-bar .right-icon img').attr({
        'onclick': 'SJBindex.like("Item", "' + dapeiId + '", this)'
      });
      if (mainImgData.like_id) {
        thisPage.find('.bottom-bar .right-icon img').attr({
          'src': 'images/icons/liked2.png',
          'onclick': 'SJBindex.like("Item", "' + dapeiId + '", this, true)'
        });
      }
      if (mainImgData.user.is_following === "0" || !mainImgData.user.is_following) {
        thisPage.find('.attention').attr({
          'onclick': 'SJBindex.follow("'+ mainImgData.user.user_id +'", this)'
        });
      } else if (mainImgData.user.is_following === "1") {
        thisPage.find('.attention').css({
          'background': '#ddd',
          'color': '#222'
        }).attr({
          'onclick': 'SJBindex.follow("' + mainImgData.user.user_id + '", this, true)'
        }).text('取消关注');
      }
      return thisPage;
    }
  },
  singleDetail: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '宝贝详情',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    createPage: function(singleId) {
      $.ajax({
        url: SJBindex.protocol + '//' + SJBindex.host + '/matters/' + singleId + '.json',
        dataType: 'JSON',
        data: {
          like: 0,
          page: 1
        },
        success: function(data) {
          var likes = data.item.likes || [];
          var comments = data.item.comments || [];
          var likesCount = Math.min(likes.length, 6);
          var commentsCount = Math.min(comments.length, 3);
          var $theLike;
          thisPage.find('.like-count').text(likes.length);
          thisPage.find('.comment-count').text(comments.length);
          for (var i = likesCount - 1; i >= 0; i--) {
            $theLike = thisPage.find('.s-d-c-avatar.template').clone().removeClass('template');
            $theLike.children('img').attr({
              'src': likes[i].avatar_img_small,
              'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + likes[i].user_id + '"))'
            });
            $theLike.prependTo(thisPage.find('.likes-user'));
          }
          if (6 < likes.length) {
            thisPage.find('.more-like-btn').show().attr('onclick', 'SJBindex.pushNewPage(SJBindex.moreLikePage.createPage(null, "' + singleId + '"))');
          }
          for (var i = 0; i < commentsCount; i++) {
            $theComment = thisPage.find('.comment-item.template').clone().removeClass('template');
            $theComment.find('.comment-avatar').children('img').attr({
              'src': comments[i].user.avatar_img_small,
              'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + comments[i].user_id + '"))'
            });
            $theComment.find('.comment-user-name').text(comments[i].user.display_name);
            $theComment.find('.comment-date').text(comments[i].created_at.slice(0, 11));
            $theComment.find('.comment-content').text(comments[i].comment);
            $theComment.appendTo(thisPage.find('.comments-detail'));
          }
          thisPage.find('.more-comments-btn').attr('onclick', 'SJBindex.pushNewPage(SJBindex.moreCommentPage.createPage(null, "'+ (comments[0] && comments[0].commentable_id) +'"))');
          if (3 < comments.length) {
            thisPage.find('.more-comments-btn').show();
          }
        }
      });
      var thisPage = $('.page.single-detail.page-template').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      thisPage.find('.main-img>img').attr('src', SJBdataCache.singles[singleId].big_png);
      thisPage.find('.p-name').text(SJBdataCache.singles[singleId].title);
      thisPage.find('.p-price').text(SJBdataCache.singles[singleId].price);
      thisPage.find('.p-buy-domain').text('来自：' + SJBdataCache.singles[singleId].buy_domain);
      thisPage.find('.p-brand').html('品牌：<span style="font-weight: bold; text-decoration: underline;">' + SJBdataCache.singles[singleId].brand_name + '</span>');
      // thisPage.find('.p-gobuy').attr({
      //   'onclick': 'SJBindex.pushNewPage(SJBindex.buyPage.createPage(\'' + SJBdataCache.singles[singleId].buy_url + '\'))' 
      // });
      thisPage.find('.p-gobuy').attr({
        'onclick': 'SJBindex.prompt("请下载搭配蜜书购买")'
      });
      thisPage.find('.bottom-bar .left-icon img').attr({
        'onclick': 'SJBindex.showComment("' + singleId+ '", "Matter")'
      });
      thisPage.find('.bottom-bar .right-icon img').attr({
        'onclick': 'SJBindex.like("Matter", "' + singleId + '", this)'
      });
      if (Number(SJBdataCache.singles[singleId].like_id)) {
        thisPage.find('.bottom-bar .right-icon img').attr({
          'src': 'images/icons/liked2.png',
          'onclick': 'SJBindex.like("Matter", "' + singleId + '", this, true)'
        });
      }
      return thisPage;
    },
  },
  buyPage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '购买宝贝',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    createPage: function(url) {
      var thisPage = $('.page.help-page.page-template').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      thisPage.append('<iframe width="100%" height="100%" src="' + url + '"></iframe>');
      return thisPage;
    }
  },
  loginPage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '登录',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    createPage: function() {
      var thisPage = $('.page.login-page.page-template').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      return thisPage;
    }
  },
  lcPage: { // like and collection page
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '喜欢与收藏',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    toggle: function(that) {
      $('.lc-page .list').hide();
      $('.' + $(that).attr('class') + '-list').show();
      $('.lc-current-nav').removeClass('lc-current-nav');
      $(that).addClass('lc-current-nav');
    },
    colHeight: [0, 0],
    nextSinglePage: 1,
    createPage: function() {
      var that = this;
      var thisPage = $('.page.lc-page').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
        $.ajax({
          url: SJBindex.protocol + '//' + SJBindex.host + '/users/' + SJBindex.user.user_id + '/favorite_matters.json?page='+ this.nextSinglePage +'&token='+ SJBindex.user.token,
          data: {
            like: 1
          },
          dataType: 'JSON',
          cache: false,
          success: function(data) {
            SJBdataCache.singles = SJBdataCache.singles || {};
            var nextItem, whichCol;
            for (var i = 0; i < data.matters.length; i++) {
              nextItem = $('.templates>.single-item').clone();
              nextItem.children('img').attr({
                'src': data.matters[i].big_png,
                'min-height': '3rem',
                'single_id': data.matters[i].object_id
              }).click(function(i) {
                var reali = i;
                return function() {
                  that.itemClickFn(data.matters[reali].object_id);
                }
              }(i));
              nextItem.find('.single-item-brand').text(data.matters[i].brand_name);
              nextItem.find('.single-item-price').text(data.matters[i].price);
              whichCol = that.colHeight[0] < that.colHeight[1] ? 0 : 1;
              that.colHeight[whichCol] += Number(data.matters[i].h);
              nextItem.appendTo(thisPage.find('.lc-single-list').children().eq(whichCol));
              SJBdataCache.singles[data.matters[i].object_id] = data.matters[i];
            }
            this.nextSinglePage++;
          }
        });
        $.ajax({
          url: SJBindex.protocol + '//' + SJBindex.host + '/users/'+ SJBindex.user.user_id +'/favorite_dapeis.json',
          cache: false,
          dataType: 'JSON',
          success: function(data) {
            var nextItem;
            ajaxState = 1;
            for (var i = 0; i < data.dapeis.length; i++) {
              data.dapeis[i].like_id = Number(data.dapeis[i].like_id);
              nextItem = $('.templates>.arrange-item').clone();
              nextItem.find('.arrange-item-like-heart>img').attr({
                'onclick': 'SJBindex.like("Item", "' + data.dapeis[i].dapei_id + '", this)'
              });
              if (data.dapeis[i].like_id) {
                nextItem.find('.arrange-item-like-heart>img').attr({
                  'src': 'images/icons/liked.png',
                  'onclick': 'SJBindex.like("Item", "' + data.dapeis[i].dapei_id + '", this, true)'
                });
              }
              nextItem.find('.arrange-item-img>img').attr({
                'src': data.dapeis[i].img_urls_large[0].img_url,
                'dapei_id': data.dapeis[i].dapei_id
              }).click(function(i) {
                var reali = i;
                return function() {
                  that.itemClickFn(data.dapeis[reali].dapei_id);
                }
              }(i));
              nextItem.find('.arrange-item-avatar>img').attr({
                'src': data.dapeis[i].user.avatar_img_small,
                'userid': data.dapeis[i].user.user_id,
                'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + data.dapeis[i].user.user_id + '"))'
              });
              nextItem.find('.arrange-item-name').text(data.dapeis[i].user.name);
              nextItem.find('.arrange-item-like-count').text(data.dapeis[i].likes_count);
              nextItem.appendTo($('.lc-page .lc-arrange-list'));
              SJBdataCache.dapeis[data.dapeis[i].dapei_id] = data.dapeis[i]; // 保存返回的搭配数据
            }
          }
        });
      return thisPage;
    }
  },
  helpPage: {
     header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '帮助教程',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    createPage: function() {
      var thisPage = $('.page.help-page.page-template').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      $.ajax({
        url: SJBindex.protocol + '//' + SJBindex.host + '/sjb/daren_applies/user_help?type=help',
        dataType: 'text',
        data: {
          like: 0,
          page: 1
        },
        success: function(data) {
          thisPage.append(data);
        }
      });
      return thisPage;
    }
  },
  suggestionPage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '意见反馈',
      right: {
        icon: 'finish',
        clickFn: undefined
      }
    },
    createPage: function() {
      var thisPage = $('.page.suggestion-page').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      return thisPage;
    }
  },
  aboutUsPage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '关于问我们',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    createPage: function() {
      var thisPage=$('.page.about-us-page').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      return thisPage;
    }
  },
  pubArrangePage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '发布的搭配',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    createPage: function() {

    }
  },
  setUpPage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '通用设置',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    createPage: function() {
      var thisPage = $('.page.set-up-page').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      return thisPage;
    }
  },

  moreCommentPage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '更多评论',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    nextPage: 1,
    addNewItem: function(dapeiID, danpinID, thisPage) { // 对于搭配与单品详情的评论id不一样，请求的url也不一样，搭配传参id为搭配id，单品传参id为评论id；
      var url;
      if (dapeiID) {
        url = SJBindex.protocol + '//' + SJBindex.host + '/items/' + dapeiID + '/comments.json?limit=20';
      } else if (danpinID) {
        url = SJBindex.protocol + '//' + SJBindex.host + '/matters/' + danpinID + '/comments.json?limit=20';
      }
      $.ajax({
        url: url, 
        data: {
          page: this.nextPage,
          like: 0,
          token: SJBindex.user.token
        },
        dataType: 'JSON',
        success: function(data) {
          var list = thisPage.find('.list');
          var comments = data.comments || [];
          for (var i = 0; i < comments.length; i++) {
            $theComment = thisPage.find('.comment-item.template').clone().removeClass('template');
            $theComment.find('.comment-avatar').children('img').attr({
              'src': comments[i].user.avatar_img_small,
              'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + comments[i].user_id + '"))'
            });
            $theComment.find('.comment-user-name').text(comments[i].user.display_name);
            $theComment.find('.comment-date').text(comments[i].created_at.slice(0, 11));
            $theComment.find('.comment-content').text(comments[i].comment);
            $theComment.appendTo(list);
          }
        }
      });
      
    },
    createPage: function(dapeiID, danpinID) {
      var thisPage = $('.page.more-comment-page').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      this.addNewItem(dapeiID, danpinID, thisPage);
      return thisPage;
    }
  },
  moreLikePage: {
    header: {
      left: {
        icon: 'back',
        clickFn: function() {
          SJBindex.backPrev.call(this);
        }
      },
      title: '更多喜欢',
      right: {
        icon: null,
        clickFn: undefined
      }
    },
    nextPage: 1,
    addNewItem: function(dapeiID, danpinID, thisPage) {
      var url;
      if (dapeiID) {
        url = SJBindex.protocol + '//' + SJBindex.host + '/items/' + dapeiID + '/liked_users.json?limit=20';
      } else if (danpinID) {
        url = SJBindex.protocol + '//' + SJBindex.host + '/matters/' + danpinID + '/liked_users.json?limit=20';
      }
      $.ajax({
        url: url,
        data: {
          page: this.nextPage,
          like: 0,
          token: SJBindex.user.token
        },
        dataType: 'JSON',
        success: function(data) {
          var list = thisPage.find('.list');
          var likes = data.users || [];
          for (var i = 0; i < likes.length; i++) {
            $thelike = thisPage.find('.like-item.template').clone().removeClass('template');
            $thelike.find('.like-avatar').children('img').attr({
              'src': likes[i].avatar_img_small,
              'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + likes[i].user_id + '"))'
            });
            $thelike.find('.like-user-name').text(likes[i].display_name);
            // $thelike.find('.like-date').text(likes[i].created_at.slice(0, 11));
            $thelike.find('.like-content').text('发布' + likes[i].dapei_count + '个搭配 粉丝：' + likes[i].followers_count + '个');
            if (likes[i].is_following === "0") {
              $thelike.find('.attention').attr({
                'onclick': 'SJBindex.follow("'+ likes[i].user_id +'", this)'
              });
            } else if (likes[i].is_following === "1") {
              $thelike.find('.attention').css({
                'background': '#ddd',
                'color': '#222'
              }).attr({
                'onclick': 'SJBindex.follow("' + likes[i].user_id + '", this, true)'
              }).text('取消关注');
            }
            $thelike.appendTo(list);
          }
        }
      });
    },
    createPage: function(dapeiID, danpinID) {
      var thisPage = $('.page.more-like-page').clone().addClass('current-page');
      thisPage.prepend(SJBindex.setHeader(this.header));
      this.addNewItem(dapeiID, danpinID, thisPage);
      SJBindex.scrollLoad(thisPage, SJBindex.moreLikePage);
      return thisPage;
    }
  },
  setBaseSize: function() {
    $('html').css('font-size', SJBenvironment.windowW / 6.4); // 6.4 取决于设计稿的尺寸，6.4对应的设计稿宽度为640px；
  },
  follow: function(id, that, unfollow) { // id 被关注的用户id， that 关注按钮节点，
    if (!SJBindex.checkLogin()) {
      return false;
    }
    if (unfollow) {
      $.ajax({
        type: 'delete',
        url: SJBindex.protocol + '//' + SJBindex.host + '/users/'+ id +'/follows/' + SJBindex.user.user_id + '.json?token=' + SJBindex.user.token,
        success: function() {
          $(that).css({
            'background': 'rgb(252, 92, 91)',
            'color': '#fff'
          }).attr({
            'onclick': 'SJBindex.follow("' + id + '", this)'
          }).text('加关注');
        }
      });
      return;
    } else {
      $.post(SJBindex.protocol + '//' + SJBindex.host + '/users/'+ id +'/follows.json?token=' + SJBindex.user.token,{}, function(){
        $(that).css({
          'background': '#ddd',
          'color': '#222'
        }).attr({
          'onclick': 'SJBindex.follow("' + id + '", this, true)'
        }).text('取消关注');
      });
    }
  },
  showComment: function(id, type) {
    if (!SJBindex.checkLogin()) {
      return false;
    }
    var pal = $('.comment-text.template').clone().removeClass('template').addClass('inWork');
    pal.attr({
      comment_type: type,
      comment_id: id
    });
    pal.find('#td1>div').css({
      'background': 'url('+ SJBindex.user.avatar_img_small +')',
      'background-size': 'cover'
    });
    pal.appendTo($('.current-page').eq(0));
  },
  hideComment: function() {
    $('.comment-text.inWork').remove();
  },
  deleteComent: function(id) {
    
  },
  comment: function(that) { // 这个函数同时兼具评论与删除评论的功能，如果只有传id则为删除评论
    $(that).parents('.comment-text').remove();
    $.post(SJBindex.protocol + '//' + SJBindex.host + '/comments.json?token=' + SJBindex.user.token, {
      comment: {
        target_type: $(that).parents('.comment-text').attr('comment_type'),
        target_id: $(that).parents('.comment-text').attr('comment_id'),
        comment: $(that).parents('.comment-text').find('#comment-content').val()
      }
    }, function() {
        var nextItem;
        var currentPage = $('.current-page');
        var theCount = Number(currentPage.eq(0).find('.comment-count').text());
        currentPage.eq(0).find('.comment-count').text(theCount + 1);
        if (currentPage.eq(0).find('.comment-item').length > 3) {
          currentPage.eq(0).find('.more-comments-btn').show();
          nextItem = currentPage.eq(0).find('.comment-item').eq(-1);
        } else {
          nextItem = currentPage.eq(0).find('.comment-item.template').clone().removeClass('template');
        }
        nextItem.find('.avatar>img').attr('src', SJBindex.user.avatar_img_medium);
        nextItem.find('.comment-content').text($(that).parents('.comment-text').find('#comment-content').val());
        nextItem.find('.comment-date').text('刚刚');
        nextItem.find('.comment-user-name').text(SJBindex.user.display_name);
        nextItem.prependTo(currentPage.find('.comments-detail'));
      }
    );
  },
  like: function(type, id, that, unlike) { // 这个函数用于喜欢或取消喜欢一个对象,参数中that表示触发时间的dom对象，
    if (!SJBindex.checkLogin()) {
      return false;
    }
    var typeMap = {
      Item: 'dapeis',
      Sku: 'singles'
    };
    var like = 'like';
    var liked = 'liked';
    if ($(that).parent().hasClass('right-icon')) {
      like = 'like2';
      liked = 'liked2';
    }
    var currentPage = $('.current-page');
    var theCount = Number(currentPage.eq(0).find('.like-count').text());
    if (unlike) {
      $.get(SJBindex.protocol + '//' + SJBindex.host + '/social/dislike.json',{
        target_type: type,
        target_id: id,
        token: SJBindex.user.token
      }, function(data) {
        currentPage.eq(0).find('.like-count').text(theCount - 1);
        $(that).attr({
          'src': 'images/icons/'+ like +'.png',
          'onclick': 'SJBindex.like("' + type + '", "' + id + '", this)'
        });
        $(that).parent().siblings('.arrange-item-like-count').text(Number($(that).parent().siblings('.arrange-item-like-count').text()) - 1);
        SJBdataCache[typeMap[type]][id].like_id = 0;
      });
      return;
    }
    $.post(SJBindex.protocol + '//' + SJBindex.host + '/social/likes.json?token=' + SJBindex.user.token, {
      "like": {
        "target_type": type,
        "target_id": id
      }
    }, function() {
        currentPage.eq(0).find('.like-count').text(theCount + 1);
        $(that).attr({
          'src': 'images/icons/'+ liked +'.png',
          'onclick': 'SJBindex.like("' + type + '", "' + id + '", this, true)'
        });
        $(that).parent().siblings('.arrange-item-like-count').text(Number($(that).parent().siblings('.arrange-item-like-count').text()) + 1);
        SJBdataCache[typeMap[type]][id].like_id = 1;
      }
    );
  },
  goToChannel: function(whichChannel) {
    var that = this,
        lastLink = $('.channel-link-current'),
        nextLink = $('#' + whichChannel);
    $('.current-channel').removeClass('current-channel');
    $('.' + whichChannel + '-channel').addClass('current-channel');
    lastLink.removeClass('channel-link-current').children('img').attr('src', 'images/icons/' + lastLink.attr('id') + '.png');
    nextLink.addClass('channel-link-current').children('img').attr('src', 'images/icons/' + nextLink.attr('id') + '_current' + '.png');
    !that.channelInfo[whichChannel].loadState && that.channelInfo[whichChannel].loadFn() && that.scrollLoad($('.' + whichChannel + '-channel'), SJBindex.channelInfo[whichChannel]);
    that.channelInfo[whichChannel].loadState = 1;
    SJBindex.inertiaScroll($('.current-channel'));
  },
  scrollLoad: function($page, page) { // 使用滚动加载的page注意内部结构适合本函数
    var that = this;
    var top = $('#return-top');
    top.click(function() {
      $page.animate({
        'scrollTop': 0
      }, 120);
    });
    $page.scroll(function() {
      if (this.scrollTop > 100) {
        top.show();
      } else {
        top.hide();
      }
      $(this).children('.list').height() - this.scrollTop - SJBenvironment.windowH < 200 && ajaxState && page.addNewItem();
    });
  },
  inertiaScroll: function($page) {
    var scrollTopArr = [0,0];
    $page.scroll(function() {
      var top = this.scrollTop;
      var time = new Date().getTime();
      scrollTopArr.push([top, time]);
      scrollTopArr.shift();
    });
    var touchend = function() {
      var v = (scrollTopArr[1][0] - scrollTopArr[0][0]) / (scrollTopArr[1][1] - scrollTopArr[0][1]);
      var sign = v > 0 ? '+' : '-';
      var s = sign + '=' + 300 * Math.abs(v);
      var t = 500 * Math.abs(v);
      $page.animate({
        scrollTop: s
      }, t);
      console.log(t);
    };
    $page[0].addEventListener('touchend', touchend, false);
  },
  setHeader: function(headerInfo) { // headerInfo 是一个dict，包含header中的所需信息。
    var $header = $('.templates>.header').clone();
    var leftIconSrc = headerInfo.left.icon,
        rightIconSrc = headerInfo.right.icon;
    leftIconSrc && $header.children('.header-left-icon').children('img').attr('src', 'images/icons/' + headerInfo.left.icon + '.png').click(headerInfo.left.clickFn);
    rightIconSrc && $header.children('.header-right-icon').children('img').attr('src', 'images/icons/' + headerInfo.right.icon + '.png').click(function() { 
    });
    $header.children('.header-title').html(headerInfo.title);
    headerInfo.pendEle && $header.prependTo(headerInfo.pendEle());
    return $header;
  },
  pushNewPage: function(thisPage) {
    SJBindex.inertiaScroll(thisPage);
    thisPage.prependTo('body').addClass('z' + (this.z++)).animate({
      'left': 0
    }, 300).removeClass('page-template');
    $('#bottom-channel').css('bottom', -60);
  },
  backPrev: function() {
    $(this).parents('.page').remove();
    SJBindex.z == 2 && $('#bottom-channel').css('bottom', 0);
    SJBindex.z--;
  }
};
var SJBdataCache = SJBdataCache || {};
