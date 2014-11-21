App.controller("dapei", function(page, data){

    var dapeiId = data.dapei_id;

    console.log(dapeiId);

    var thisPage = $(page);

    $.ajax({
        url: '/dapeis/get_dp_items/' + dapeiId + '.json',
        dataType: 'JSON',
        data: {
            like: 0,
            page: 1
        },
        success: function(data) {
            var tdStr;
            for (var i = 0; i < 6; i++) {
                if (i < data.items.length) {
                    tdStr = '<td>'+
                        '<div class="item-img" style="background: url(' + data.items[i].img_normal_small + ') center center no-repeat; background-size: contain;"></div>'+
                        '<div class="item-brand">' + data.items[i].brand_name + '</div></td>';
                } else {
                    tdStr = '<td></td>'
                }
                !(i % 3) && $(page).find('.arrange-zone table').append('<tr></tr>');
                $(page).find('.arrange-zone table tbody').append(tdStr);
            }
        }
    });

    $.ajax({
        url: '/dapeis/'+ dapeiId +'/get_dapei_detail.Json?token='+ dapeiId,
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
            thisPage.find('.like-count').text(data.dapei.likes_count);
            thisPage.find('.comment-count').text(data.dapei.comments_count);
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
                $theComment.find('.comment-date').text(comments[i].created_at);
                $theComment.find('.comment-content').text(comments[i].comment);
                $theComment.appendTo(thisPage.find('.comments-detail'));
            }
            thisPage.find('.more-comments-btn').attr('onclick', 'SJBindex.pushNewPage(SJBindex.moreCommentPage.createPage("'+ dapeiId +'", null))');
            if (3 < comments.length) {
                thisPage.find('.more-comments-btn').show();
            }

            thisPage.find('.main-img>img').attr('src', data.dapei.img_url);
            thisPage.find(".main-img-info .avatar img").attr('src', data.dapei.user_avatar);
            thisPage.find(".a-d-m-sometext .username").text(data.dapei.username);
            thisPage.find(".a-d-m-sometext .desc").text(data.dapei.user_desc);
        }
    });
});

