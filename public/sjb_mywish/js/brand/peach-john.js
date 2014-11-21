	var scanIntervals=50;
	function isSingleProd() {
		if ($("#ItemViewForm").length > 0) {
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
				return '蜜桃派';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return '蜜桃派';
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
            
			function _getSingleProduct() {
				if ($('span.prd_name').length > 0) {
					result.name = $('span.prd_name').text().trim();
				}
                
                var $oldPrice = $('#product-purchase-info-oldPrice');
				if ($oldPrice.length > 0) {
                    var price = $oldPrice.text().trim();
                    if(price != '') {
                        result.oriPrice = price;
                    }
                }
                
				if ($("#product-purchase-info-price").length > 0) {
					result.promotionPrice = $("#product-purchase-info-price").text().trim();
				}
				
				if ($("#product-purchase-info-skuCode").length > 0) {
					result.refNo = $("#product-purchase-info-skuCode").text().trim();
				}
                
				if ($("#product-selector-swatch-btns-color a").length > 0) {
                    var colors = [];
                    $("#product-selector-swatch-btns-color a").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).find("span.button-label").text().trim();
                        colorOption.src = (window.location.origin || window.location.protocol + "//" + window.location.host) + $(this).find("span.color-chip img").attr("src");
                        if ($(this).hasClass("pseudo-selected")) {
                            colors.unshift(colorOption);
                        }else {
                            colors.push(colorOption);
                        }
                    });
                    
					result.colors = colors;
				}
				if ($("#product-selector-swatch-btns-size li").length > 0) {
					var sizes = [];
					$("#product-selector-swatch-btns-size li").each(function() {
						sizes.push($(this).find("span.button-label").text().trim());
					});
					
					result.sizes = sizes;
				}	
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
				_formatResult();
                
				return result;
			}
		};
	};