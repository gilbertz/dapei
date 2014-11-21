	var scanIntervals=50;
	function isSingleProd() {
		if ($("#product-detail").length > 0) {
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
				return 'Omega';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Omega';
			},
			
			/**
			 * get if the product can be bought
			 */
			getBuyOnline : function() {
				return false;
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
				if ($("#title-header > h1").length > 0) {
					result.name = $("#title-header > h1").find('span').eq(0).text().trim() + ' ' + $("#title-header > h1").find('span').eq(1).text().trim();
				}
                
				if ($('#product-detail span.reference-number').length > 0) {
					result.refNo = $('#product-detail span.reference-number').text().trim();
				}
  
				if ($('ul.color-list').find('li img').length > 0) {
				    var colors = [];
				    $('ul.color-list').find('li img').each(function() {
	                    var colorOption = {};
	                    colorOption.title = "";
	                    colorOption.src = $(this).attr('src');
	                    
	                    colors.push(colorOption);    
				    });
				    
				    result.colors = colors;
                }
				
                // can not capture color
//                if ($('#product-detail ul.techlist').find('li').length >= 5) {
//                    var sizes = [];
//                    sizes.push($('#product-detail ul.techlist').find('li').eq(4).find('p').text().trim());
//
//                    result.sizes = sizes;
//                }
				if ($('.title').length > 0) {
				    var sizes = [];
				    $('.title').each(function() {
				        if ($(this).text().indexOf('尺寸') > -1) {
		                    sizes.push($(this).next().text().trim());
		                    result.sizes = sizes;

		                    return;
				        }
				    });
				}
				
                if ($('.leather-border-top').length > 0) {
                    var sizes = [];
                    $('.leather-border-top').each(function() {
                        if ($(this).text().indexOf('尺寸') > -1) {
                            sizes.push($(this).next().find('p').contents()[0].data.trim());
                            result.sizes = sizes;

                            return;
                        }
                    });
                }
                
                if ($('#product-gallery div').length > 0) {
                    $('#product-gallery div').each(function() {
                        if ($(this).css('display') == 'block') {
                            result.mainImage = $(this).find('img').attr("src");
                            return;
                        }
                    });
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