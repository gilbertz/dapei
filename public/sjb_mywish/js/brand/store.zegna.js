	var scanIntervals=50;
	function isSingleProd() {
		if ($("#item").length > 0) {
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
				return 'Zegna';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Zegna';
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
				if ($('#itemInfo h1').length > 0) {
					result.name = $('#itemInfo h1').text().trim();
				}
                
                var $oldPrice = $('#itemPrice div.oldprice:visible');
				if ($oldPrice.length > 0) {
                    var price = $oldPrice.text().trim();
                    if(price != '') {
                        result.oriPrice = price;
                    }
                }
                
                var $newPrice = $("#itemPrice div.newprice:visible");
				if ($newPrice.length > 0) {
                    var price = $newPrice.text().trim();
                    if(price != "") {
                        result.promotionPrice = price;
                    }
				}
				
				if ($("#itemCode").length > 0) {
                    var refNoStr = $("#itemCode").text().trim(),
                        refNo = refNoStr.substring(10).trim();
                    if (refNo != "") {
                        result.refNo = refNo;
                    } else if (jsinit_item) {
                        result.refNo = jsinit_item.CURRENTITEM.code;
                    }
				}
                
				if ($("#itemColors li").length > 0) {
                    var colors = [];
                    $("#itemColors li").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).text().trim();
                        
                        if ($(this).hasClass("selected")) {
                            colors.unshift(colorOption);
                        }else {
                            colors.push(colorOption);
                        }
                    });
                    
					result.colors = colors;
				}
				if ($("#itemSizes li").length > 0) {
					var sizes = [];
					$("#itemSizes li").each(function() {
						sizes.push($(this).text().trim());
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
				result.location = 'US';
				result.currency = 'USD';
				getMetaInfo(cBrand);
				_formatPrice();
				_formatResult();
                
				return result;
			}
		};
	};