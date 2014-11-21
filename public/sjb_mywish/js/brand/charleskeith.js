var scanIntervals=50;
function isSingleProd() {
    if ($('#main-content form').length > 0) {
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
            return 'Charles & Keith';
        },

        /**
         * get the current brand name
         */
        getCurrentBrandName : function() {
            return 'Charles & Keith';
        },
        
        /**
         * get if the product can be bought
         */
        getBuyOnline : function() {
            return true;
        }/* ,
            
        getGoodImgSize : function() {
            return {
                maxWidth: 600,
                maxHeight: 600
            };
        } */
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

            if ($("#originalPrice").length > 0) {
                result.oriPrice = $("#originalPrice").text().trim();
            }
            
            if ($("span.prd_big_offer_price").length > 0) {
                result.promotionPrice = $("span.prd_big_offer_price").text().trim();
            }
            
            if ($("span.prd-code").length > 0) {
                var refStr = $("span.prd-code").text().trim();
                result.refNo = refStr.substring(5).trim();
            }
            
            if ($("a.color").length > 0) {
                var colors = [];
                $("a.color").each(function() {
                    var colorOption = {},
                        $img = $(this).find("img");
                    colorOption.title = $(this).attr("title");
                    colorOption.src = $img.attr("src");
                    if ($(this).hasClass("selected")) {
                        colors.unshift(colorOption);
                    }else {
                        colors.push(colorOption);
                    }
                });
                
                result.colors = colors;
            }
            
            if ($("#sizeList a").length > 0) {
                var sizes = [];
                $("#sizeList a").each(function() {
                    sizes.push($(this).text().trim());
                });
                
                result.sizes = sizes;
            }
            
            if ($('img.prd_preview_img').length > 0) {
                result.mainImage = $('img.prd_preview_img').attr('src');
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