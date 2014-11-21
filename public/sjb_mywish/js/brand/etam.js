	var scanIntervals=50;
	function isSingleProd() {
		if ($("body.catalog-product-view").length > 0) {
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
				return 'Etam';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Etam';
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
				if ($("div.product-shop .product-name h1").length > 0) {
					result.name = $("div.product-shop .product-name h1").text().trim();
				}

				if ($("div.product-shop .price-box .regular-price ").length > 0) {
                    result.oriPrice = $("div.product-shop .price-box .regular-price .price").text().trim();
                }
				if ($("div.product-shop .price-box .special-price").length > 0) {
					result.promotionPrice = $("div.product-shop .price-box .special-price").text().trim();
                    result.oriPrice = $("div.product-shop .price-box .old-price .price").text().trim();
				}
				if ($("div.product-shop .price").length > 0) {
					result.vipPrice = $("div.product-shop .price:last").text();
				}
				
				if ($("div.product-shop .sku").length > 0) {
					var refNo = $("div.product-shop .sku").text().trim();
					result.refNo = refNo.substring(4);
				}
				if ($("div.user-action-area .product-options dd:first").length > 0) {
                    var colors = [];
                    var colorOption = {};
                    colorOption.title = $("div.user-action-area .product-options dd:first").text().trim();
                    colors.push(colorOption);
					result.colors = colors;
				}
				if ($("div.flat-options span").length > 0) {
					var sizes = [];
					$("div.flat-options span").each(function() {
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
			if (result.vipPrice) {
				result.vipPrice = _getPriceNum(result.vipPrice);
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