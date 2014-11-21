    var scanIntervals=50;
    function isSingleProd() {
        if ($("#product-details-box").length > 0) {
            return true;
        } else {
            return false;
        }
    }
    /**
     * Object, supported sites collections with brand names
     */
    var productBrand = function() {
        var isOriginals = ($("div.product-name h1").text().indexOf('三叶草') > -1);
        var brand = isOriginals ? "三叶草" : "adidas";
        var brandName = isOriginals ? "三叶草" : "阿迪达斯";
        
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
                return brand;
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return brandName;
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return false;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 300,
                    minHeight: 300,
                    maxWidth: 699,
                    maxHeight: 699
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
                if ($("div.product-name > h1").length > 0) {
                    result.name = $("div.product-name > h1").text().trim();
                }
                //add refNo here, maybe not the wanted refNo
                if ($("p.current-color").length > 0) {
                    var refNo = $('p.current-color').contents()[1].data.trim();
                    result.refNo = refNo.substring(refNo.indexOf('(') + 1, refNo.indexOf(')'));
                }
                
                if ($('span.regular-price').length > 0) {
                    result.oriPrice = $('span.regular-price').text().trim();
                }
                if ($('p.old-price').length > 0) {
                    result.oriPrice = $('p.old-price').text().trim();
                    result.promotionPrice = $('p.special-price7').text().trim();
                }
                
                if ($("div.color-selection .product-image img").length > 0) {
                    var colors = [];
                    $("div.color-selection .product-image img:first").each(function() {
                        var colorOption = {};
                        var colorStr = $('p.current-color').contents()[1].data.trim();
                        colorStr = colorStr.substr(0, colorStr.indexOf('('));
                        colorOption.title = colorStr;
                        colorOption.src = $(this).attr('src');
                        
                        colors.push(colorOption);
                    });
                    
                    result.colors = colors;
                }
                
                if ($('div.size-box li a').length > 0) {
                    var sizes = [];
                    $("div.size-box li a").each(function() {
                        sizes.push($(this).text().trim());
                    });

                    result.sizes = sizes;
                }
                
                if ($("#zoom1 img").length > 0) {
                    result.mainImage = $("#bigimgwrap img").attr("src");
                }
            }

            function _getListProduct() {
                result.oriPrice = _getPrice(imgNode);
                var container = imgNode.parentNode.parentNode.parentNode;
                result.name = $(container).children("div.productName").children().text().trim();                    
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
                        if(nodes[i].innerHTML && nodes[i].innerHTML.indexOf("￥")!=-1){
                            return nodes[i].innerHTML.trim();
                        }
                        if(nodes[i].nodeValue && nodes[i].nodeValue.indexOf("￥")!=-1){
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
                _formatResult();
                _formatPrice();

                return result;
            }
        };
    };

/*	var scanIntervals=50;
	function isSingleProd() {
		if ($("div.PDP_MasterHeroWrapper").length > 0) {
			return true;
		} else {
			return false;
		}
	}
	*//**
	 * Object, supported sites collections with brand names
	 *//*
	var productBrand = function() {
	    var isOriginals = ($("div.BreadCrumb li").eq(2).find("a").text() == "Originals");
	    var brand = isOriginals ? "三叶草" : "adidas";
	    var brandName = isOriginals ? "三叶草" : "阿迪达斯";
	    
		return {
			*//**
			 * get the current site domain
			 *//*
			getCurrentDomain : function() {
				return document.domain || '';
			},

			*//**
			 * get the current brand
			 *//*
			getCurrentBrand : function() {
				return brand;
			},

			*//**
			 * get the current brand name
			 *//*
			getCurrentBrandName : function() {
				return brandName;
			},
            
            *//**
			 * get if the product can be bought
			 *//*
			getBuyOnline : function() {
				return false;
			}
		};
	}();

	var Product = function(imgNode) {
		var imgSrc = imgNode ? imgNode.src : '';

		var result = {};

		*//**
		 * redirect to methods according to brand name
		 * 
		 * @param {string}
		 *            brand's name
		 *//*
		var getMetaInfo = function() {
			if (isSingleProd()) {
				_getSingleProduct();
			} else {
				//_getListProduct();
			}

			result.tags = _getTags();
			
			function _getSingleProduct() {
				if ($("div.HeroHeader > h2").length > 0) {
					result.name = $("div.HeroHeader > h2").first().text().trim();
				}
                //add refNo here, maybe not the wanted refNo
                if ($("div.infoWrapper span.model").length > 0) {
                    var refNo = $("div.infoWrapper span.model").text().trim();
                    result.refNo = refNo.substring(1, refNo.length - 1);
                }
                
                if ($("ul.proList li").length > 0) {
					var colors = [];
					$("ul.proList li").each(function() {
                        var colorOption = {};
						colorOption.title = $("div.infoWrapper span").eq(1).text().trim();
                        colorOption.src = $(this).find('img').attr('src');
                        
						colors.push(colorOption);
					});
					
					result.colors = colors;
				}
                
				if ($("#zoom1 img").length > 0) {
					result.mainImage = $("#bigimgwrap img").attr("src");
				}
			}

			function _getListProduct() {
				result.oriPrice = _getPrice(imgNode);
				var container = imgNode.parentNode.parentNode.parentNode;
				result.name = $(container).children("div.productName").children().text().trim();					
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
						if(nodes[i].innerHTML && nodes[i].innerHTML.indexOf("￥")!=-1){
							return nodes[i].innerHTML.trim();
						}
						if(nodes[i].nodeValue && nodes[i].nodeValue.indexOf("￥")!=-1){
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

		*//**
		 * Get the number from the price string.
		 * 
		 * @param {String}
		 *            priceString the price string,such as '399.00 CNY'.
		 *//*
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
				_formatResult();

				return result;
			}
		};
	};*/