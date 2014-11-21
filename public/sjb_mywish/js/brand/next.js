	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.itemsContainer").length > 0) {
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
				return 'Next';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Next';
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
                var $article = $('section.ProductDetail article.Selected');
                if ($article.length > 0) {
                    if ($article.find('div.Title').length > 0) {
                        result.name = $article.find('div.Title').text().trim();
                    }
                    if ($article.find('div.ItemNumber').length > 0) {
                        result.refNo = $article.find('div.ItemNumber').text().trim();
                    }
                    if ($article.find("div.Price").length > 0) {
                        result.oriPrice = $article.find("div.Price").text().trim();
                    }
                    
                    if ($article.find("select.subStyleList").length > 0) {
                        var colors = [];
                        $article.find("select.subStyleList").find('option').each(function() {
                            var colorOption = {},
                                titleStr = $(this).text();
                            colorOption.title = titleStr.substring(0, titleStr.indexOf('(')).trim();
                            if ($(this).attr('selected') == 'selected') {
                                colors.unshift(colorOption);
                            } else {
                                colors.push(colorOption);
                            }
                        });
                        
                        result.colors = colors;
                    }
                    
                    if ($article.find("select.SizeSelector").length > 0) {
                        var sizes = [];
                        $article.find("select.SizeSelector").find('option.InStock').each(function() {
                            sizes.push($(this).text().trim());
                        });
                        
                        result.sizes = sizes;
                    }
                }
				
			}

			function _getListProduct() {
				var container = imgNode.parentNode;
				result.name = $(container).children("div.productinfo").children(".product-name").text().trim();
				result.oriPrice = $(container).children("div.productinfo").children(".prodPrice").children().text().trim();				
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
				result.location = 'UK';
				result.currency = 'GBP';
				getMetaInfo(cBrand);
                _formatPrice();
				_formatTags();
				_formatResult();

				return result;
			}
		};
	};