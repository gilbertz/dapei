	var scanIntervals=50;
	function isSingleProd() {
		if ($("#pdpMain").length > 0) {
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
				return 'Versace';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Versace';
			},
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 440,
                    minHeight: 620
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
                if ($('div.product-info div.selected').length > 0) {
                    $product = $('div.product-info div.selected');
                    
                    if ($product.find("h1.productname").length > 0) {
                        result.name = $product.find("h1.productname").text().trim();
                    }
                    
                    if ($product.find("div.salesprice").length > 0) {
                        /* if ($("div.salesprice").hasClass('hasStandardPrice')) {
                            result.oriPrice = $("div.salesprice").text().trim();
                        } else {
                            result.oriPrice = $("div.salesprice").text().trim();
                        } */
                        result.oriPrice = $product.find("div.salesprice").text().trim();
                    }
                    
                    if ($product.find("div.standardprice").length > 0) {
                        result.promotionPrice = $product.find("div.standardprice").text().trim();
                    }
                    
                    if ($product.find('div.productid span').length > 0) {
                        result.refNo = $product.find('div.productid span').text().trim();
                    }
                
                    if ($product.find('li.product-param').length > 0) {
                        var colors = [];
                        $product.find('li.product-param').each(function() {
                            var colorOption = {},
                                srcStr = $(this).css('background-image');
                            colorOption.title = $(this).find('a').attr('title');
                            colorOption.src = srcStr.substring(srcStr.indexOf('(') + 1, srcStr.indexOf(')')).trim().replace('"', '');
                            if ($(this).hasClass('selected')) {
                                colors.unshift(colorOption);
                            } else {
                                colors.push(colorOption);
                            }
                        });
                        
                        result.colors = colors;
                    }
                    
                    if ($product.find('select.size option').length > 0) {
                        var sizes = [];
                        $product.find('select.size option').each(function(i) {
                            if (i) {
                                sizes.push($(this).text());
                            }
                        });
                        
                        result.sizes = sizes;
                    }
                }
			}

			function _getListProduct() {
				var container = imgNode.parentNode.parentNode.parentNode.parentNode;
				result.name = $(container).children("h5").children().text().trim();
				result.oriPrice = $(container).children("div.price-box").children().children().children().text().trim();			
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
            if (priceString.match(regNum)) {
                var priceNum = priceString.match(regNum)[0];
                return trim(priceNum);
            } else {
                return trim(priceString);
            }
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
				result.location = 'US';
				result.currency = 'USD';
				getMetaInfo(cBrand);
				_formatPrice();
				_formatTags();
				_formatResult();

				return result;
			}
		};
	};