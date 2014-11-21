	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.goodsParament").length > 0) {
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
				return '哥弟';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return '哥弟';
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
				if ($("p.goodsParamentName").length > 0) {
					result.name = $("p.goodsParamentName").text().trim();
				}
                if ($("#goodsPrice").length > 0) {
                    if ($('p.goodsPrice_p s').length > 0) {
                        result.oriPrice = $("p.goodsPrice_p s").text().trim();
                        result.promotionPrice = $("#goodsPrice").text().trim();
                    } else {
                        result.oriPrice = $("#goodsPrice").text().trim();
                    }
				}
                
				if ($("p.goodsNumber").length > 0) {
                    var refNoStr = $("p.goodsNumber").first().text().trim();
					result.refNo = refNoStr.substring(refNoStr.indexOf('：') + 1).trim();
				}
                if ($("p.goodsPrice_p span.priceName").length > 0) {
                    $("p.goodsPrice_p span.priceName").each(function() {
                        if ($(this).text() == "货号") {
                           result.refNo = $(this).next().text().trim();
                           
                           return;
                        }
                    });
                }
				if ($("div.currentColor img").length > 0) {
					var colors = [];
					$("div.currentColor img").each(function() {
                        var colorOption = {},
                            srcStr = $(this).attr("src"),
                            origin = window.location.origin || window.location.protocol + '//' + window.location.host;
						colorOption.title = $(this).attr('title');
						colorOption.src = origin + '/' + srcStr.substring(0, srcStr.indexOf('?'));
						if ($(this).parent().hasClass('sizeSele')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
					});
					
					result.colors = colors;
				}
				if ($("span.sizeNumSpan").length > 0) {
					var sizes = [];
					$("span.sizeNumSpan").each(function() {
                        sizes.push($(this).text().trim());
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
