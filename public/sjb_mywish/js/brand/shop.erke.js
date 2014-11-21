var scanIntervals=50;
function isSingleProd() {
    if ($("div.zi").length > 0) {
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
            return '鸿星尔克';
        },

        /**
         * get the current brand name
         */
        getCurrentBrandName : function() {
            return '鸿星尔克';
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
                minHeight: 800,
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
            if ($("div.zi h1").length > 0) {
                result.name = $("div.zi h1").text().trim();
            }

            if ($("font.shop").length > 0) {
                result.promotionPrice = $("font.shop").text().trim();
            }
            
            if ($("#NKS_SHOPPRICE").length > 0) {
                result.oriPrice = $("#NKS_SHOPPRICE").text().trim();
            }
            
            if ($("div.qian li").length > 3) {
                $("div.qian li").each(function() {
                    var text = $(this).text();
                    if (text.indexOf('商品货号') > -1) {
                        result.refNo = text.substring(5).trim();
                        return false;
                    }
                });
            }
            
            if ($("#choose_pz > li").length > 0) {
                var colors = [];
                $("#choose_pz > li").each(function() {
                    var colorOption = {};
                    colorOption.title = $(this).find("a").text().trim();
                    if ($(this).hasClass("hover")) {
                        colors.unshift(colorOption);
                    }else {
                        colors.push(colorOption);
                    }
                });
                
                result.colors = colors;
            }
            
            if ($("#choose_ys > li").length > 0) {
                var sizes = [];
                $("#choose_ys > li").each(function() {
                    sizes.push($(this).find("a").text().trim());
                });
                
                result.sizes = sizes;
            }
            
            if ($('#spec-n1 img').length > 0) {
                result.mainImage = $('#spec-n1 img').attr('src');
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
            result.location = 'CN';
            result.currency = 'CNY';
            getMetaInfo(cBrand);
            _formatPrice();
            _formatTags();
            _formatResult();

            return result;
        }
    };
};