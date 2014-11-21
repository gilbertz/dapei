	var scanIntervals=50;
	function isSingleProd() {
		if ($('#TB_iframeContent').length > 0) {
			return $('#TB_iframeContent');
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
				return 'Puma';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Puma';
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
                var $iframeBody = $($('#TB_iframeContent')[0].contentWindow.document.body);
				if ($iframeBody.find('#description h1').length > 0) {
					result.name = $iframeBody.find('#description h1').text().trim();
				}
				
                if ($iframeBody.find('div.desc').length > 0) {
                    var desc = $iframeBody.find('div.desc').text().trim();
                    result.oriPrice = desc.substr(desc.lastIndexOf('：') + 1).trim();
                    
                    var sizeStr = desc.substring(desc.indexOf('尺寸：') + 3);
                    sizeStr = sizeStr.substr(0, sizeStr.indexOf(")") + 1);
                    var sizes = [];
                    sizes.push(sizeStr);

                    result.sizes = sizes;
                }
                
                if ($iframeBody.find("#product_ids").length > 0) {
                    result.refNo = $iframeBody.find("#product_ids").text().trim();
                }
                // no color words info
			}

			function _getListProduct() {
				result.name = imgNode.alt || imgNode.title|| document.title;					
			}
			
			function _getTags() {
				var tags = '';
				return tags;
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
				_formatTags();
				_formatPrice();
				_formatResult();

				return result;
			}
		};
	};