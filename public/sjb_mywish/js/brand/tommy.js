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
				return 'Tommy Hilfiger';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return '汤美希绯格';
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
				if ($("#product-name h1").length > 0) {
					result.name = $("#product-name h1").text().substring(0, $("#product-name h1").text().indexOf('Tommy Hilfiger')).trim();
				}
				if ($("div.price-box del").length > 0) {
                    result.oriPrice = $("div.price-box del").text().trim();
                    result.promotionPrice = $("div.price-box span").text().trim();
				} else if($("span.regular-price").length > 0) {
				    result.oriPrice = $("span.regular-price").text().trim();
				} 

				if ($("span.gId").length > 0) {
                    var refNoStr = $("span.gId").text().trim();
					result.refNo = refNoStr.substring(refNoStr.indexOf(':') + 1).trim();
				}
                
                if ($("div.color a").length > 0) {
                    var colors = [];
                    $("div.color a").each(function() {
                        var colorOption = {};
						colorOption.title = $(this).find('img').attr("title");
                        colorOption.src = $(this).find('img').attr("src");
						colors.push(colorOption);
                    });

                    result.colors = colors;
                }
                if ($("div.size a").length > 0) {
                    var sizes = [];
                    $("div.size a").each(function() {
                        sizes.push($(this).text().trim());
                    });

                    result.sizes = sizes;
                }
				if ($("#image").length > 0) {
					result.mainImage = $("#image").attr("src");
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