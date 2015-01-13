http://www.shangjieba.com:8080/users/zheng-xie-chang-wei363808/favorite_dapeis.json?like=1&page=1&token=zheng-xie-chang-wei363808

http://www.shangjieba.com:8080/users/' + SJBindex.user.userId + '/favorite_dapeis.json?like=1&page='+ this.nextSinglePage +'&token='+ SJBindex.user.userId
http://www.shangjieba.com:8080/users/' + SJBindex.user.userId + '/favorite_items.json?page='+ this.nextSinglePage +'&token='+ SJBindex.user.userId

$.post('http://www.shangjieba.com:8080/social/likes.json?token=pj8JFpnPrmdH72kznCcf',{
  "like": {
    "target_type": "Sku",
    "target_id":"132323"
  }
}, function(data) {
console.log(data)}
)// 喜欢一个单品