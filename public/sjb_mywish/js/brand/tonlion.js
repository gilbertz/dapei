﻿	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.GoodsInfoWrap").length > 0) {
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
				return '唐狮';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return '唐狮';
			},
            
            /**
			 * get if the product can be bought
			 */
			getBuyOnline : function() {
				return true;
			},
            
            getGoodImgSize : function() {
                return {
                    minWidth: 300,
                    minHeight: 300
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
				_getSingleProduct();
			} else {
				//_getListProduct();
			}

			result.tags = _getTags();
			
			function _getSingleProduct() {
				if ($("h1.goodsname").length > 0) {
					result.name = $("h1.goodsname").text().trim();
					if (result.name.indexOf("#") > -1) {
					    result.name = result.name.substr(0, result.name.indexOf("#") - 1);
					}
				}

                if ($("span.price1").length > 0) {
					result.oriPrice = $("span.price1").text().trim();
				}
				if ($("i.mktprice1").length > 0) {
					result.promotionPrice = $("i.mktprice1").text().trim();
				}
				if ($("#goodsBn").length > 0) {
					var refNo = $("#goodsBn").text().trim();
					result.refNo = refNo.substr(0, refNo.length - 1);
				}
				if ($("tr.specItem").length > 0) {
				    $("tr.specItem").each(function() {
				        if ($(this).find("li img").length > 0) {
				            var colors = [];
				            $(this).find("li img").each(function() {
		                        var colorOption = {};
		                        colorOption.title = $(this).attr('title');
		                        colorOption.src = $(this).attr('src');
		                        if ($(this).parent().hasClass("selected")) {
		                            colors.unshift(colorOption);    
		                        } else {
		                            colors.push(colorOption);
		                        }
		                    });
		                    
		                    result.colors = colors;        
				        } else if ($(this).find("li span").length > 0) {
				            var sizes = [];
				            $(this).find("li span").each(function() {
		                        sizes.push($(this).text().trim());
		                    });
		                    
		                    result.sizes = sizes;
				        }
				    })
					
				}
				
				result.mainImage = $("div.goods-detail-pic img").attr("src");
			}

			function _getListProduct() {
                result.name = imgNode.alt || imgNode.title|| document.title;		
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