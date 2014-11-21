	var scanIntervals=50;
	function isSingleProd() {
		return false;
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
				return '';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return '';
			}
		};
	}();

	var Product = function(imgNode) {
		var imgSrc = imgNode ? imgNode.src : '';

		var result = {};

		var _formatResult = function() {
			for ( var key in result) {
				if (!result[key]) {
					delete result[key];
				}
			}
		};

		return {
			getProductInfo : function() {
				result = {};
				// some uri maybe had been encoded, so decode it before encode
				result.imagePath = encodeURI(decodeURI(imgSrc));
				result.sourceUrl = encodeURI(decodeURI(top.document.URL));
				var domain = top.document.domain;
				
                if (domain.indexOf('www.belle') > -1) {
                    result.brand = '百丽';
                } else if (domain.indexOf('.verawang.') > -1) {
                    result.brand = 'Vera Wang';
                } else if (domain.indexOf('.izzue') > -1) {
                    result.brand = 'Izzue';
                    result.name = $('div.zoomWrapperTitle').text().trim();
                } else if (domain.indexOf('escada') > -1) {
                    result.brand = 'Escada';
                } else if (domain.indexOf('isseymiyake') > -1) {
                    result.brand = 'Issey Miyake';
                }

//				var index = domain.indexOf('.com');
//				var nDomain = domain.substring(0, index).split('.');
//				var len = nDomain.length;
//				
//				result.brand = nDomain[len - 1].replace(/\w+\b/g, function(
//						word) {
//					return word.substring(0, 1).toUpperCase()
//							+ word.substring(1);
//				});
				
//				result.name = imgNode.alt || imgNode.title|| document.title;
				return result;
			}
		};
	};