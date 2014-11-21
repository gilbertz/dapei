	var scanIntervals=50;
	function isSingleProd() {
		if ($("#productCrumbs").length > 0) {
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
				return 'Nine West';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Nine West';
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
				if ($("#pNameHOne").length > 0) {
					result.name = $("#pNameHOne").text().trim();
				}

				var priceEle = $("div.PDPPriceArea .onSale");
				if (priceEle.length > 0 && priceEle.text().trim() != '') {
                    result.oriPrice = priceEle.text().trim();
                    result.promotionPrice = $("div.PDPPriceArea .salePrice").text().trim();
                } else if ($("div.PDPPriceArea .notSale").length > 0) {
                    result.oriPrice = $("div.PDPPriceArea .notSale").text().trim();
                }
				
				if (configData) {
					result.refNo = configData.productId; // Defined in the website by itself
				}
				if ($("#colorChips img").length > 0) {
					var colors = [];
					var colorOption = {};
					colorOption.title = $("#colorChips img.selectedColorButton").attr("title");
                    colorOption.src = $("#colorChips img.selectedColorButton").attr("src");

					colors.push(colorOption);
					result.colors = colors;
				}
				
				var sizesElement = $("#sizes");
                
				if (sizesElement.length > 0 && sizesElement.attr("style") != "display: none;") {
					var sizes = [];
					sizesElement.find("span:visible").each(function() {
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