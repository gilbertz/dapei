	var scanIntervals=50;
	function isSingleProd() {
		if ($(".mode").length > 0) {
			return false;
		} else {
			return true;
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

			getCurrentBrand : function() {
				var domain = top.document.domain;
				var brand = $("h3.shop-title > a").first().text();
				var index = brand.indexOf('官方旗舰店');
				brand = brand.substring(0,index);
				return brand;
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				var domain = top.document.domain;
				var brand = $("h3.shop-title > a").first().text();
				var index = brand.indexOf('官方旗舰店');
				brand = brand.substring(0,index);
				return brand;
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
				result.name = imgNode.alt || imgNode.title|| document.title;
				result.oriPrice = $("#J_StrPrice").first().text();
				result.refNo = '';
			}

			function _getListProduct() {
				var container = imgNode.parentNode.parentNode.parentNode;
				result.oriPrice = $(container).children().eq(2).children().eq(1).text().trim();
				result.name = $(container).children().eq(1).children().text().trim();					
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
				//_formatPrice();
				_formatTags();
				_formatResult();

				return result;
			}
		};
	};