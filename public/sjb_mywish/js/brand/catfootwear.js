	var scanIntervals=50;
	function isSingleProd() {
		if ($("#news").length > 0) {
			return $("#news");
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
				return 'CAT';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'CAT';
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
				if ($("span.productname").length > 0) {
					result.name = $("span.productname").text().trim();
				}
                
				var $iframeBody = $($("#news")[0].contentWindow.document.body),
                    imgSrc = '';
                if ($iframeBody.find("img").length > 0) {
                    imgSrc = $iframeBody.find("img").attr("src");
                    result.refNo = imgSrc.substring(imgSrc.lastIndexOf("/") + 1, imgSrc.lastIndexOf('.'));
                }
                
                if ($("span.productname").parent().parent().parent().parent().parent().parent().next().find('img').length > 0) {
                    var colors = [];
                    $("span.productname").parent().parent().parent().parent().parent().parent().next().find('img').each(function() {
                        var colorOption = {},
                            srcStr = $(this).attr('src'),
                            hrefStr = window.location.href,
                            hrefPrefix = imgSrc.substring(0, imgSrc.lastIndexOf("/")) || hrefStr.substring(0, hrefStr.indexOf('/html/'));
                        colorOption.title = '';
                        colorOption.src = hrefPrefix + srcStr.substring(srcStr.lastIndexOf('/'));
                        if (imgSrc.indexOf(srcStr.substring(srcStr.lastIndexOf('/'))) > -1) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
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
				_formatTags();
				_formatResult();

				return result;
			}
		};
	};