	var scanIntervals=50;
	function isSingleProd() {
		if ($("#goods_base").length > 0) {
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
				return '太平鸟';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return '太平鸟';
			},
            
            /**
			 * get if the product can be bought
			 */
			getBuyOnline : function() {
				return true;
			},
            
            getGoodImgSize : function() {
                return {
                    minWidth: 750,
                    minHeight: 579
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
				if ($("div.goods_right_parameters div.t").length > 0) {
					result.name = $("div.goods_right_parameters div.t").text().trim();
				}

                if ($("b.hot2:visible").length > 0) {
                    if ($('span.zg del').length > 0) {
                        result.oriPrice = $('span.zg del').text().trim();
                        result.promotionPrice = $("b.hot2:visible").text().trim();
                    } else {
                        result.oriPrice = $("b.hot2:visible").text().trim();
                    }
				}

                if ($("#goods_sn").length > 0) {
					result.refNo = $("#goods_sn").text().trim();
				}
				if ($("ul.spec_img li").length > 0) {
					var colors = [];
					$("ul.spec_img li").each(function() {
                        var colorOption = {},
                            srcStr = $(this).css('background-image');
						colorOption.title = $(this).attr('spec_value');
						colorOption.src = srcStr.substring(srcStr.indexOf('(') + 1, srcStr.indexOf(')')).replace('"', '');
                        if ($(this).find('i').css('display') == 'block') {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
					});
					
					result.colors = colors;
				}
				if ($("ul.spec_size li").length > 0) {
					var sizes = [];
					$("ul.spec_size li").each(function() {
                        sizes.push($(this).text().trim());
					});
					
					result.sizes = sizes;
				}
                
                if ($('div.big_pic img').length > 0) {
                    result.mainImage = $('div.big_pic img').attr("src");
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