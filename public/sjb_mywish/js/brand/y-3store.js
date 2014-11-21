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
				return 'Y-3';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Y-3';
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
				if ($("#col1 .itemTitle").length > 0) {
					result.name = $("#col1 .itemTitle").text().trim();
				}

				if (jsoninit_item) {
					result.refNo = jsoninit_item.CURRENTITEM.code;
				}
				
                
                if ($('#priceCumulative .itemBoxPrice').length > 0) {
                    result.oriPrice = $('#priceCumulative .itemBoxPrice').text();
                }
				
				if ($("#priceCumulative div.oldprice").length > 0) {
					result.oriPrice = $("#priceCumulative div.oldprice").text().trim();
				}
                
                if ($("#priceCumulative div.newprice").length > 0) {
                    result.promotionPrice = $("#priceCumulative div.newprice").text().trim();
                }
                if ($("#colorsBoxContainer div.colorBoxIn").length > 0) {
                    var colors = [];
                    $("#colorsBoxContainer div.colorBoxIn").each(function() {
                        var colorOption = {};
						colorOption.title = $(this).attr("title");
						if ($(this).parent().hasClass("colorBoxSelected")) {
							colors.unshift(colorOption);
						} else {
							colors.push(colorOption);
						}
                    });

                    result.colors = colors;
                }
                if ($("#sizesBoxContainer div.sizeBoxIn").length > 0) {
                    var sizes = [];
                    $("#sizesBoxContainer div.sizeBoxIn").each(function() {
                        sizes.push($(this).text().trim());
                    });

                    result.sizes = sizes;
                }
			}

			function _getListProduct() {
				result.name = imgNode.alt || imgNode.title|| document.title;				
			}
			
			function _getPrice(node){
				var container = node.parentNode;
				var price=_findSubling(container);
				if(price!=''){
					return price;
				}else if(container.parentNode){
					return _getPrice(container);
				}
				return '';
			}

			function _findSubling(node){
				var nodes = node.childNodes;
				for(var i=0;i<nodes.length;i++){
					if(nodes[i].nodeType==1){
						if(nodes[i].innerHTML && nodes[i].innerHTML.indexOf("��")!=-1){
							return nodes[i].innerHTML.trim();
						}
						if(nodes[i].nodeValue && nodes[i].nodeValue.indexOf("��")!=-1){
							return nodes[i].nodeValue.trim();
						}
					}
				}
				return '';
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
			var priceString = priceString.substring(1).trim();
			return priceString;
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