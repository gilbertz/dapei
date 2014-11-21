success: function(data) {
            var nextItem;
            ajaxState = 1;
            for (var i = 0; i < data.dapeis.length; i++) {
              data.dapeis[i].like_id = Number(data.dapeis[i].like_id);
              nextItem = $('.templates>.lc-arrange-item').clone();
              nextItem.find('.lc-arrange-item-like-heart>img').attr({
                'onclick': 'SJBindex.like("Item", "' + data.dapeis[i].dapei_id + '", this)'
              });
              if (data.dapeis[i].like_id) {
                nextItem.find('.lc-arrange-item-like-heart>img').attr({
                  'src': 'images/icons/liked.png',
                  'onclick': 'SJBindex.like("Item", "' + data.dapeis[i].dapei_id + '", this, true)'
                });
              }
              nextItem.find('.lc-arrange-item-img>img').attr({
                'src': data.dapeis[i].img_urls_large[0].img_url,
                'dapei_id': data.dapeis[i].dapei_id
              }).click(function(i) {
                var reali = i;
                return function() {
                  that.itemClickFn(data.dapeis[reali].dapei_id);
                }
              }(i));
              nextItem.find('.lc-arrange-item-avatar>img').attr({
                'src': data.dapeis[i].user.avatar_img_small,
                'userid': data.dapeis[i].user.user_id,
                'onclick': 'SJBindex.pushNewPage(SJBindex.homePage.createPage("' + data.dapeis[i].user.user_id + '"))'
              });
              nextItem.find('.lc-arrange-item-name').text(data.dapeis[i].user.name);
              nextItem.find('.lc-arrange-item-like-count').text(data.dapeis[i].likes_count);
              nextItem.appendTo($('.lc-arrange-channel>.list'));
              SJBdataCache.dapeis[data.dapeis[i].dapei_id] = data.dapeis[i]; // 保存返回的搭配数据
            }
            that.nextPage++;
          }