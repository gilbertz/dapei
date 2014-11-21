	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.detail_main_bg").length > 0) {
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
				return 'Converse';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return '匡威';
			},
            
            /**
			 * get if the product can be bought
			 */
			getBuyOnline : function() {
				return true;
			},
            
            getGoodImgSize : function() {
                return {
                    minWidth: 600,
                    minHeight: 400,
                    maxWidth: 650,
                    maxHeight: 450
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
				if ($("#detail_content_wrapper h1").length > 0) {
					result.name = $("#detail_content_wrapper h1").text().trim();
				}

				if ($("#fullscreen_thumb").length > 0) {
					result.refNo = $("#fullscreen_thumb").attr("skuCode");
				}
				
				if ($("#skuPrice").length > 0) {
				    if ($("#retailPrice").length > 0) {
	                    result.oriPrice = $("#retailPrice").text().trim();
                        result.promotionPrice = $("#skuPrice").text().trim();
				    } else {
	                    result.oriPrice = $("#skuPrice").text().trim();
				    }
				}
				// if ($(".product-id").length > 0) {
					// result.refNo = $(".product-id").text().trim();
				// }
				if ($("#color_select a span").length > 0) {
                    var colors = [];
                    $("#color_select a span").each(function(i) {
                        var colorOption = {};
						colorOption.title = $(this).attr("title");
						if ($(this).parent().hasClass('posi')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });

                    result.colors = colors;
                }
                if ($("div.size_box li span").length > 0) {
                    var sizes = [];
                    $("div.size_box li span").each(function(i) {
                   		sizes.push($(this).text());
                    });
                    
                    result.sizes = sizes;
                }
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