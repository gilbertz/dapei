	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.fiche_produit")) {
			return true;
		} else {
			return false;
		}
	}
	/**
	 * Object, supported sites collections with brand names
	 */
	var productBrand = function() {
		return {
			/**
			 * get the current site domain
			 */
			getCurrentDomain : function() {
				return document.domain || '';
			},

			/**
			 * get the current brand
			 */
			getCurrentBrand : function() {
				return 'Dior';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Dior';
			},
			
			/**
			 * get if the product can be bought
			 */
			getBuyOnline : function() {
				return false;
			},
            
            getGoodImgSize : function() {
                return {
                    minWidth: 200,
                    minHeight: 200,
                    maxWidth: 800,
                    maxHeight: 800
                };
            }
		};
	}();

	var Product = function(imgNode) {
		var imgSrc = imgNode ? imgNode.src : '';

		var result = {};

		/**
		 * redirect to methods according to brand name
		 * 
		 * @param {string}
		 *            brand's name
		 */
		var getMetaInfo = function() {
			if (isSingleProd()) {
				_getSingleProductHm();
			} else {
//				_getListProductHm();
			}

			result.tags = _getTagsHM();
			
			function _getSingleProductHm() {
				if ($("span.subtitle").length > 0) {
					result.name = $("span.subtitle").text().trim();
				} else if ($("li.img-link p").length > 0) {
                    result.name = $("li.img-link p").text().trim().replace("。", "");
				}
                
                if ($("#accordion p").length > 0) {
					result.refNo = $("#accordion p").last().text().trim();
				}
                
                if ($('img.miniature').length > 0) {
                    $('img.miniature').each(function() {
                        if ($(this).css('display') != 'none') {
                            result.mainImage = $(this).attr("src");
                            return;
                        }
                    });
                }
			}

			function _getListProductHm() {
				result.oriPrice = _getPrice(imgNode);
				var container = imgNode.parentNode.parentNode;
				result.name = $(container).children("a" > "span").text().trim();			
			}
			
			function _getPrice(node){
				var container = node.parentNode;
				var price=_findSubling(container);
				if(price!=''){
					return price;
				}else if(container.parentNode){
					return _getPrice(container);
				}
				return '';
			}

			function _findSubling(node){
				var nodes = node.childNodes;
				for(var i=0;i<nodes.length;i++){
					if(nodes[i].nodeType==1){
						if(nodes[i].innerHTML && nodes[i].innerHTML.indexOf("￥")!=-1){
							return nodes[i].innerHTML.trim();
						}
						if(nodes[i].nodeValue && nodes[i].nodeValue.indexOf("￥")!=-1){
							return nodes[i].nodeValue.trim();
						}
					}
				}
				return '';
			}
			
			function _getTagsHM() {
				var tags = '';
				return tags;
			}
		};

		/**
		 * Get the number from the price string.
		 * 
		 * @param {String}
		 *            priceString the price string,such as '399.00 CNY'.
		 */
		var _getPriceNum = function(priceString) {
			var priceString = priceString || '';
			var regNum = /\d+([,，]\d+)*(\.\d+)?/;
			var priceNum = priceString.match(regNum)[0];
			return trim(priceNum);
		};

		var _formatPrice = function() {
			if (result.oriPrice) {
				result.oriPrice = _getPriceNum(result.oriPrice);
			}
			if (result.promotionPrice) {
				result.promotionPrice = _getPriceNum(result.promotionPrice);
			}
		};

		var _formatTags = function() {
			var newTags = [];
			var tmp = {};
			if (result.tags) {
				newTags = result.tags.split('&&');
				result.tags = [];
				for ( var i = 0, len = newTags.length; i < len; i++) {
					if (newTags[i]) {
						tmp = {
							'name' : newTags[i]
						};
						result.tags.push(tmp);
					}
				}
			} else {
				delete result.tags;
			}
		};

		var _formatResult = function() {
			for ( var key in result) {
				if (!result[key]) {
					delete result[key];
				}
			}
		};

		return {
			getProductInfo : function() {
				var cBrand = productBrand.getCurrentBrand();
				result = {};
				// some uri maybe had been encoded, so decode it before encode
				result.imagePath = encodeURI(decodeURI(imgSrc));
				result.sourceUrl = encodeURI(decodeURI(top.document.URL));

								result.brand = productBrand.getCurrentBrandName();
				result.location = 'CH';
				result.currency = 'CNY';
				getMetaInfo(cBrand);
				_formatPrice();
				_formatTags();
				_formatResult();

				return result;
			}
		};
	};