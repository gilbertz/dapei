	var scanIntervals=50;
	function isSingleProd() {
		return true;
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
				return 'Geox';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Geox';
			},
			
			/**
			 * get if the product can be bought
			 */
			getBuyOnline : function() {
				return true;
			},
            
            getGoodImgSize : function() {
                return {
                    minWidth: 150,
                    minHeight: 150
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
			    var nameNode = $("#info h1 span:first"),
			    refNode = $("#swatch img"),
			    priceNode = $("#info h1 span:last"),
			    colorNodes = $("#swatch img"),
			    sizeNodes = $("#select-size option");
			    
				if (nameNode.length > 0) {
					result.name = nameNode.text().trim();
				}

                if (refNode.length > 0) {
                    var refVal = refNode.attr('alt').trim();
                    result.refNo = refVal;
                }
                
				if (priceNode.length > 0) {
                    result.oriPrice = priceNode.text().trim();
                }
				
				if (colorNodes.length > 0) {
					var colors = [];
					colorNodes.each(function() {
                        var colorOption = {};
						colorOption.title = '';
                        colorOption.src = $(this).attr("src");
                        if ($(this).parent().hasClass("selected")) {
                        	colors.unshift(colorOption);
                        } else {
                        	colors.push(colorOption);
                        }
					});
					
					result.colors = colors;
				}
                
				if (sizeNodes.length > 0) {
					var sizes = [];
					sizeNodes.each(function() {
					    var size = $(this).text();
						sizes.push(size.substr(0, size.indexOf('-')).trim());
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