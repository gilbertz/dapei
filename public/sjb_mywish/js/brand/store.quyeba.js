	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.goods-info-wrap").length > 0) {
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
				return 'The North Face';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'The North Face';
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
				if ($("#main-info h2.goodsname").length > 0) {
                    var text = $("#main-info h2.goodsname").text().trim();
                    var refNo = $("#main-info h2.goodsname").contents()[0].data.trim();
                    var reg = / ([A-Z0-9]+( |$))/;
                    var regArr = refNo.match(reg);
                    if (regArr.length > 1) {
                        result.refNo = regArr[1];
                        result.name = text;
                    } else {
                        result.name = text;
                    }
				}
                
				if ($("#main-info .basic-info p").length > 1 && $("#main-info .basic-info span").eq(1).text().indexOf("价格") > -1) {
                    result.oriPrice = $("#main-info .basic-info p").eq(1).text().trim();
                    result.promotionPrice = $("#main-info p.goods-brief em").text().trim();
				} else if ($("#main-info p.goods-brief em").length > 0) {
                    result.oriPrice = $("#main-info p.goods-brief em").text().trim();
                }

                if ($("div.spec-item").eq(0).find('li').length > 0) {
                    var colors = [];
                    $("div.spec-item").eq(0).find('li').each(function() {
                        var colorOption = {};
						colorOption.title = $(this).find('img').attr("title");
                        colorOption.src = $(this).find('img').attr("src");
                        if ($(this).find("a").hasClass("selected")) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });

                    result.colors = colors;
                }
                if ($("div.spec-item").eq(1).find('li').length > 0) {
                    var sizes = [];
                    $("div.spec-item").eq(1).find('li').each(function() {
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