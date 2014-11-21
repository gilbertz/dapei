var scanIntervals=50;
function isSingleProd() {
    if ($("div.product-detail").length > 0) {
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
            return 'ECCO';
        },

        /**
         * get the current brand name
         */
        getCurrentBrandName : function() {
            return 'ECCO';
        },
        
        /**
         * get if the product can be bought
         */
        getBuyOnline : function() {
            return true;
        },
            
        getGoodImgSize : function() {
            return {
                maxWidth: 2000,
                maxHeight: 2000
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
            if ($("#share-product-title").length > 0) {
                result.name = $("#share-product-title").text().trim();
            }

            if ($("span.price-normal").length > 0) {
                result.oriPrice = $("span.price-normal").text().trim();
            }else {
                if ($("span.price-sales").length > 0) {
                    result.oriPrice = $("span.price-sales").text().trim();
                }
                
                if ($("span.price-standard").length > 0) {
                    result.promotionPrice = $("span.price-standard").text().trim();
                }
            }
            
            if ($("#share-product-id").length > 0) {
                result.refNo = $("#share-product-id").text().trim();
            }
            
            if ($("ul.Color > li").length > 0) {
                var colors = [];
                $("ul.Color > li").each(function() {
                    if ($(this).find("img").length > 0) {
                        var colorOption = {},
                            $img = $(this).find("img");
                        colorOption.title = $img.attr("title");
                        colorOption.src = $img.attr("src");
                        if ($(this).hasClass("selected")) {
                            colors.unshift(colorOption);
                        }else {
                            colors.push(colorOption);
                        }
                    }
                });
                
                result.colors = colors;
            }
            
            if ($("#tabEU > ul.size > li").length > 0) {
                var sizes = [];
                $("#tabEU > ul.size > li").each(function() {
                    if ($(this).find("a").length > 0) {
                        sizes.push($(this).text().trim());
                    }
                });
                
                result.sizes = sizes;
            }
            
            if ($('img.primary-image').length > 0) {
                result.mainImage = $('img.primary-image').attr('src');
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
            result.location = 'US';
            result.currency = 'USD';
            getMetaInfo(cBrand);
            _formatPrice();
            _formatTags();
            _formatResult();

            return result;
        }
    };
};