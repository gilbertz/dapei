	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.productDetailsWrapper").length > 0) {
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
				return 'Bossini';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return '堡狮龙';
			},
            
            /**
			 * get if the product can be bought
			 */
			getBuyOnline : function() {
				return true;
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
				_getSingleProduct();
			} else {
				//_getListProduct();
			}

			result.tags = _getTags();
			
			function _getSingleProduct() {
				if ($("div.productSummaryContainer .productTitle").length > 0) {
					result.name = $("div.productSummaryContainer .productTitle").text().trim();
				}
                //add refNo here, maybe not the wanted refNo
                if ($("div.productDescContainer .productIntroContentMainBg p").length > 0) {
                    var refNo = $("div.productDescContainer .productIntroContentMainBg p:first").text().trim();
                    result.refNo = refNo.substr(refNo.indexOf(":") + 1);
                }
                if ($("div.productSummaryContainer .listing_product_price").length > 0) {
					if ($("div.productSummaryContainer .listing_product_price .originalPrice").length > 0) {
						result.oriPrice = $("div.productSummaryContainer .listing_product_price .originalPrice").text().trim();
						result.promotionPrice = $("div.productSummaryContainer .listing_product_price .discountedPrice").text().trim();
					} else {
						result.oriPrice = $("div.productSummaryContainer .listing_product_price b").text().trim();
					}
				}
                if ($("div.colorContainer .color").length > 0) {
					var colors = [];
					$("div.colorContainer .color img").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title");
                        colorOption.src = $(this).attr("src");
                        if ($(this).parent().parent().hasClass("colorBoxHighlight")) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
					});
					
					result.colors = colors;
				}
                if ($("div.sizeContainer a").length > 0) {
					var sizes = [];
					$("div.sizeContainer a").each(function() {
						if (this.id !== "sizeChart") {
							sizes.push($(this).text().trim());
						}
					});
					
					result.sizes = sizes;
				}
                
                if ($('#currentCurrency').length > 0) {
                    if ($('#currentCurrency').text().indexOf("HKD") == -1) {
                        result.wrongWebSite = true;
                    }
                }
			}

			function _getListProduct() {
				result.oriPrice = _getPrice(imgNode);
				var container = imgNode.parentNode.parentNode.parentNode;
				result.name = $(container).children("div.productName").children().text().trim();					
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
			
			function _getTags() {
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
			// var regNum = /\d+?(,\d+)+?(\.\d+)|\d+/;
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
				result.location = 'HK';
				result.currency = 'HKD';
				getMetaInfo(cBrand);
				_formatPrice();
				_formatResult();

				return result;
			}
		};
	};