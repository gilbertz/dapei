	var scanIntervals=50;
	function isSingleProd() {
		if ($("#main-info").length > 0) {
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
				return 'UGG';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'UGG';
			},
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return false;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 400,
                    minHeight: 400
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
				if ($("h2.goodsname").length > 0) {
					result.name = $("h2.goodsname").text().trim();
				}
                
				if ($("ul.goods-info-list em.goodsprice").length > 0) {
				    if ($('del.mktprice1').length > 0) {
                        result.promotionPrice = $('del.mktprice1').text().trim();
	                    result.oriPrice = $("ul.goods-info-list em.goodsprice").text().trim();
				    } else {
	                    result.oriPrice = $("ul.goods-info-list em.goodsprice").text().trim();
				    }
				}
				
                if (result.oriPrice.indexOf('￥') == -1) {
                    result.wrongWebSite = true;
                }
                
                /* if ($("span.fontfivety font").length > 0) {
                    result.promotionPrice = $("span.fontfivety font").text().trim();
                } */
                
				if ($("#goodsBn").length > 0) {
                    result.refNo = $("#goodsBn").text().trim();
				}
            
                if ($('div.spec-values img').length > 0) {
                    var colors = [];
                    $('div.spec-values img').each(function() {
                        var colorOption = {};
						colorOption.title = $(this).attr('title');
                        colorOption.src = $(this).attr('src');
                        if ($(this).parent().hasClass('selected')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                
                if ($('div.spec-values .guige12 span').length > 0) {
                    var sizes = [];
                    $('div.spec-values .guige12 span').each(function() {
                        sizes.push($(this).text());
                    });
                    
                    result.sizes = sizes;
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
                return '';
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