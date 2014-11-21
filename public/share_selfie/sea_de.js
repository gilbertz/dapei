// ;define( function (require, exports, module) {
	// var cvs_tool = require('canvasUtil') ;

	var Details = function (ele,selfie_id) {
		this.value = selfie_id;
		this.isZipai = false;
		this.parent = this.divs(ele) ;
		this.init()  ;
	}

	Details.prototype.init = function() {
		var that = this;
	    that.postby = that.newElement('div', {id:'postby', className:'top'}) ;
	    that.meta = that.newElement('div', {id:'meta', className:'content'}) ; 
	    that.viewinfo = that.newElement('div', {id:'viewinfo', className:'bottom'}) ; 
		that.parent.appendChild(that.postby); 
		that.parent.appendChild(that.meta) ; 
		that.parent.appendChild(that.viewinfo) ;
		that.xhrLoad()  ; 
	};

	Details.prototype.xhrLoad = function() {
		var that = this, xhr = that.xhr() ; 
		xhr.onreadystatechange = callback ; 
		url = window.location.origin+"/dapeis/view/"+this.value+".json"

		xhr.open('GET', url, true) ; 
		xhr.send(null) ;  

		function callback () {

			if (xhr.readyState == 4) { // 与服务器端交互完成

				if (xhr.status == 200) { //成功获取数据
					var _backdata  ;
					try {
						_backdata = JSON.parse(xhr.responseText) ;
					} catch (e) {
						console.error(e) ;
					}

					// dapei为搭配详情， selfie为自拍详情
					that.detailsData = _backdata.dapei || (that.isZipai = true) && _backdata.selfie;  
					that.setData() ;
				} else {
					console.error('获取数据失败') ;
				}
			} 	
		}
	};

	Details.prototype.xhr = function() {
		var xhr = null ; 

		if (window.XMLHttpRequest){
			// IE7,8, FireFox, Chrome, Safari, Opera
			xhr = new XMLHttpRequest() ;
		} else if (window.ActiveXObject) {
			// IE < 7
			var activexName= ['MSXML2.XMLHTTP.6.0','MSXML2.XMLHTTP.5.0', 'MSXML2.XMLHTTP.4.0',
			                  'msxml2.xmlhttp.3.0','MSXML2.XMLHTTP.2.0', 'MSXML2.XMLHTTP.1.0'];
			for (var i = 0; i < activexName.length; i++){
				try {
					xhr = new ActiveXObject(activexName[i]) ; 
					break ;
				} catch(e) {
					console.error( e ) ;
				}
			}
		}

		if (xhr == undefined || xhr == null) {
			throw new Error('创建XMLHttpRequest对象失败');
		}

		return xhr  ;
	};

	Details.prototype.setData = function() {
		var that = this ;

		that.handleTop(that.postby) ;
		that.handleMain(that.meta) ;
		that.handleViewInfo(that.viewinfo) ;
	};

	Details.prototype.divs = function(id) {
		if (typeof id == 'string') {
			return document.getElementById(id) ;
		} 

		return null ;
	};

	Details.prototype.newElement = function( ele, attr) {
		var that = this, obj ;
		if (typeof ele == 'string'){
			obj = document.createElement(ele) ; 
			if (attr) {
				for (i in attr) {
					obj[i] = attr[i] 
				}
			}
		}

		return obj ;
	};

	Details.prototype.handleTop = function(parent) {
		var that = this , 
		    userIcon = that.newElement('div') ,  // 放置用户头像
		    userDesc = that.newElement('div') ,  // 放置用户ID，签名，等级等信息

		    icon = that.newElement('img')  ; // 用户头像

		icon.src = that.detailsData.user.avatar_img_small ;
		userIcon.appendChild(icon) ;
		parent.appendChild(userIcon);

		var name = that.newElement('h3') , 
		    desc = that.newElement('h4') , 
		    lv = that.newElement('span') ; 

		lv.innerText = that.detailsData.user.fashion_level ;
		name.innerText = that.detailsData.user.name ;
		name.appendChild(lv) ; 
		desc.innerText = that.detailsData.user.desc ;

	    userDesc.className = 'top-desc' ;
		userDesc.appendChild(name) ; 
		userDesc.appendChild(desc) ;
		parent.appendChild(userDesc);
	};

	Details.prototype.handleMain = function(parent) {
		var that = this, list, img, text, title, ul,
		    largePicDiv = that.newElement('div') ,  // 放置搭配大图的div
		    largePic = that.newElement('img') ,  // 搭配大图
		    dapeiItemsDiv , // 放置搭配items的div, 如果是自拍详情，则没有这个
		    zipaiTags ; // 自拍详情页的tag

	    // 添加搭配大图
		largePic.src = that.detailsData.img_urls_large[0].img_url ;
		if (that.isZipai) {
			largePic.onload = function () {
				// 添加自拍详情页的Tags
				zipaiTags = that.newElement('canvas') ;
				zipaiTags.width = largePic.width; 
				zipaiTags.height = largePic.height;
				zipaiTags.className = 'tag-canvas' ;

		    	that.addTags(zipaiTags) ;
		    	largePicDiv.appendChild(zipaiTags) ;
			}
		}

		largePicDiv.appendChild(largePic) ;
		parent.appendChild(largePicDiv) ;

        if (!that.isZipai){
        	// 搭配详情页
			// 添加sharetitle
			dapeiItemsDiv = that.newElement('div') ;
			dapeiItemsDiv.className = 'dapei-items' ;
			title = that.newElement('h3') ; 
			title.innerText = that.detailsData.share_title;
			dapeiItemsDiv.appendChild(title); 

			// 添加搭配物件小图 
			ul = that.newElement('ul');
			var length = (1 / that.detailsData.dapei_items.length) * 100 + '%' ;
			for (var i = 0; i < that.detailsData.dapei_items.length; i++) {
				list = that.newElement('li') ; 
				list.style.width = length;

				img = that.newElement('img') ; 
				img.src = that.detailsData.dapei_items[i].img_sqr_small ;
				list.appendChild(img) ;

				text = that.newElement('p') ; 
				text.innerText = that.detailsData.dapei_items[i].brand_name;
				list.appendChild(text) ; 

				ul.appendChild(list) ; 
			};
			dapeiItemsDiv.appendChild(ul) ;
			parent.appendChild(dapeiItemsDiv) ;
	    } 
	};

	Details.prototype.handleViewInfo = function(parent) {
		var that = this, 
		    likecount = that.newElement('div'), // 喜欢/评论数
		    likeuser = that.newElement('div'), // 喜欢的用户信息
	        h3 = that.newElement('h3'), ul, list, img; 

	    // 添加喜欢/评论数
	    h3.innerHTML = '<span><i>' + that.detailsData.likes_count + '</i>喜欢</span>' +
	                   '<span><i>' + that.detailsData.comments_count + '</i>评论</span>' ;
	    likecount.appendChild(h3) ;

	    // 添加喜欢的用户头像
	    ul = that.newElement('ul') ;
	    var length = (1 / that.detailsData.like_users.length) * 100 + '%' ;
	    for (var i = 0; i < that.detailsData.like_users.length; i++) {
	    	list = that.newElement('li') ;
	    	img = that.newElement('img') ;
	    	img.src = that.detailsData.like_users[i].avatar_img_small ; 
	    	img.title = img.alt = that.detailsData.like_users[i].name;
	    	list.style.width = length;
	    	list.appendChild(img) ;
	    	ul.appendChild(list) ;
	    };
	    likeuser.className = 'like-user' ;
	    likeuser.appendChild(ul) ;

	    parent.appendChild(likecount) ; 
	    parent.appendChild(likeuser);

	    if (ul.children[0].offsetWidth > 65) {
	    	for ( i = 0; i < ul.children.length; i++) 
	    		ul.children[i].style.width = '65px';
	    }
	};

	Details.prototype.addTags = function(parent) {
		var that = this, 
		    data = that.detailsData.img_urls_large[0] ;
		canvasTools.drawTags({data: data, canvas: parent}) ;
	};

	// module.exports = Details;
// })