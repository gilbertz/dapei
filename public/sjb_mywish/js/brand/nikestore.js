	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.dp-buying-tools-container").length > 0) {
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
				return 'Nike';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Nike';
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
				if ($("div.tools-detal h1.tools-detal-name").length > 0) {
					result.name = $("div.tools-detal h1.tools-detal-name").text().trim();
				}

				if ($("span.orgPrice").length > 0) {
                    result.oriPrice = $("span.orgPrice").text().trim();
                    if ($("span.showPrice").length > 0) {
                        result.promotionPrice = $("span.showPrice").text().trim();
                    }
                }else {
                    if ($("span.showPrice").length > 0) {
                        result.oriPrice = $("span.showPrice").text().trim();
                    }
                }
				
				if ($("div.tools-detal span.tools-detal-selected").length > 0) {
                    var str = $("div.tools-detal span.tools-detal-selected").text().trim();
					result.refNo = str.match(/\d{6}-\d{3}/)[0].trim();
				}
                
				if ($("#relatedColors ul.color-chip-container li").length > 0) {
					var colors = [];
					$("#relatedColors ul.color-chip-container li").each(function() {
                        var colorOption = {};
						colorOption.title = "";
                        colorOption.src = $(this).find('img').attr('src');
                        if ($(this).hasClass("selected")) {
                        	colors.unshift(colorOption);
                        } else {
                        	colors.push(colorOption);
                        }
						
					});
					
					result.colors = colors;
				}
                
				if ($("#size ul li").length > 0) {
					var sizes = [];
					$("#size ul li").each(function() {
						sizes.push($(this).text());
					});
					
					result.sizes = sizes;
				}
				
				if ($("img.primary-product-image").length > 0) {
					result.mainImage = $("img.primary-product-image").attr("src");
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