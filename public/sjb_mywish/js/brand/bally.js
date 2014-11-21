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
				return 'Bally';
			},

			/**
			 * get the current brand name
			 */
			getCurrentBrandName : function() {
				return 'Bally';
			},
			
			/**
			 * get if the product can be bought
			 */
			getBuyOnline : function() {
				return true;
			},
            
            getGoodImgSize : function() {
                return {
                    minWidth: 800,
                    minHeight: 500
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
				if ($("#topModelName").length > 0) {
					result.name = $("#topModelName").text().trim();
				}
				
				var urlParms = window.location.href.split("/");
				var indexCode = urlParms.indexOf("cod10");
				if (indexCode > -1) {
					result.refNo = urlParms[indexCode + 1];
				}

				if ($("#bottomElements .priceValue .oldprice").length > 0) {
					result.oriPrice = $("#bottomElements .priceValue .oldprice").text().trim();
					result.promotionPrice = $("#bottomElements .priceValue .newprice").text().trim();
				} else {
					result.oriPrice = $("#bottomElements .priceValue").text().trim();
				}
				if ($("#sizeAndColorSelection").length > 0) {
					var colors = [];
					var color = $("#sizeAndColorSelection").text().trim();
					if (color.indexOf(" -") > -1) {
						color = color.substring(0, color.indexOf(" -"));
					}
                    var colorOption = {};
						colorOption.title = color;
					colors.push(colorOption);
					
					result.colors = colors;
				}
				if ($("#sizesBoxContainerCN .sizeBoxIn").length > 0) {
					var sizes = [];
					$("#sizesBoxContainerCN .sizeBoxIn").each(function() {
						sizes.push($(this).text());
					});
					
					result.sizes = sizes;
				}
                
                if ($('li.selected img').length > 0) {
                    result.mainImage = $('li.selected img').attr("src");
                }
			}

			function _getListProduct() {
				result.oriPrice = _getPrice(imgNode);
				var container = imgNode.parentNode.parentNode;
				result.name = $(container).children("a" > "productName").text().trim();					
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