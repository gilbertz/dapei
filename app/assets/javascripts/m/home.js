function goToDapei(dapei_id){
    App.load("dapei", {dapei_id: dapei_id});
}


App.controller('home', function (page) {
    var $loading  = $(page).find('.loading'),
        $list     = $(page).find('.app-list');

    $loading.remove();
    var nextPage = 1;

    App.infiniteScroll($list, { loading: $loading }, function (callback) {
        $.ajax({
            url: "/dapeis/index_all.json",
            dataType: "JSON",
            data: {page: nextPage},
            success: function(data){
                var list = [];
                for (var i = 0; i < data.dapeis.length; i++) {
                    var str = '<div class="arrange-item">'+
                    '<div class="arrange-item-img">'+
                        '<img width="100%" onclick="goToDapei(\''+data.dapeis[i].dapei_id+'\')" src="'+data.dapeis[i].img_urls_large[0].img_url+'" dapei_id="'+data.dapeis[i].dapei_id+'">'+
                        '</div>'+
                        '<div class="arrange-item-info">'+
                        '<div class="arrange-item-avatar">'+
                            '<img width="100%" src="'+data.dapeis[i].user.avatar_img_small+'" userid="'+data.dapeis[i].user.user_id+'">'+
                            '</div>'+
                            '<div class="arrange-item-name">'+data.dapeis[i].user.name+'</div>'+
                            '<div class="arrange-item-like-count">'+data.dapeis[i].likes_count+'</div>'+
                            '<div class="arrange-item-like-heart">'+
                                '<img src="/assets/m/icons/like.png">'+
                                '</div>'+
                                '<ul class="clear"></ul>'+
                            '</div>'+
                        '</div>';

                    list.push(str);
                }

                callback(list);
                nextPage++;
            }
        });

    });

});