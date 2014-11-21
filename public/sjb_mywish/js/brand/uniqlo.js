var scanIntervals=50;
function isSingleProd() {
    if ($("#J_itemViewed").length > 0) {
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
            return document.domain || ''
        },

        /**
         * get the current brand
         */
        getCurrentBrand : function() {
            return '优衣库';
        },

        /**
         * get the current brand name
         */
        getCurrentBrandName : function() {
            return '优衣库';
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
            if ($("#detail .detail-hd h3").length > 0) {
                var name = $("#detail .detail-hd h3").text().trim();
                result.name = name.substring(name.indexOf(' ') , name.indexOf('UNIQLO'));
            }
            
            if (window.g_config) {
                result.refNo = window.g_config.itemId;
            }

            if ($("#J_StrPrice").length > 0) {
                result.oriPrice = $("#J_StrPrice").text().trim();
            }
            
            if ($("div.key .J_ulSaleProp.img a").length > 0) {
                var colors = [];
                $("div.key .J_ulSaleProp.img a").each(function() {
                    var colorOption = {},
                        srcStr = $(this).css('background-image');
                    colorOption.title = $(this).find('span').text();
                    colorOption.src = srcStr.substring(srcStr.indexOf('(') + 1, srcStr.indexOf(')')).replace('"', '');
                    if ($(this).parent().hasClass("selected")) {
                    	colors.unshift(colorOption);
                    } else {
                    	colors.push(colorOption);
                    }
                });
                
                result.colors = colors;
            }
            if ($("div.key .J_ulSaleProp").length > 0) {
                var sizes = [];
                $("div.key .J_ulSaleProp").each(function() {
                    if (!$(this).hasClass("img")) {
                        $(this).find("span").each(function() {
                            sizes.push($(this).text());
                        });
                    }
                });
                
                result.sizes = sizes;
            }    
            
			if ($("#J_ImgBooth").length > 0) {
				result.mainImage = $("#J_ImgBooth").attr("src");
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
        var regNum = /\d+([,.]\d+)*(\.\d+)?/;
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
