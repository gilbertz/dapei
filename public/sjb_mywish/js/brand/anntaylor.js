var scanIntervals=50;
function isSingleProd() {
    if ($("#widget-quickview").length > 0 || $("#ProductDetail").length > 0) {
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
            return 'Ann Taylor';
        },

        /**
         * get the current brand name
         */
        getCurrentBrandName : function() {
            return 'Ann Taylor';
        },
        
        /**
         * get if the product can be bought
         */
        getBuyOnline : function() {
            return true;
        },
            
        getGoodImgSize : function() {
            var minWidth = 0,
                minHeight = 0,
                maxWidth = 0,
                maxHeight = 0;
                
            if ($("#widget-quickview").length > 0) {
                maxHeight = 399;
                maxWidth = 325;
            }
            
            return {
                minWidth: minWidth,
                minHeight: minHeight,
                maxWidth: maxWidth,
                maxHeight: maxHeight
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
            if ($("#widget-quickview").length > 0) {
                if ($("div.hd-info").length > 0) {
                    result.name = $("div.hd-info h1").text().trim();
                }
                
                if ($("div.price").length > 0) {
                    if ($("div.price p.currentPrice").length > 0) {
                        result.oriPrice = $("div.price p.currentPrice").text().trim();
                    }
                    if ($("div.price p.previousPrice").length > 0) {
                        result.promotionPrice = $("div.price p.previousPrice").text().trim();
                    }
                }
            } else if ($("#ProductDetail").length > 0) {
                if ($("div.hd-info").length > 0) {
                    result.name = $("div.hd-info h1").text().trim();
                }

                if ($("div.price").length > 0) {
                    if ($("div.price .sale").length > 0) {
                        result.oriPrice = $("div.price .sale").text().trim();
                    }
                    if ($("div.price .was").length > 0) {
                        result.promotionPrice = $("div.price .was").text().trim();
                    }
                }
                
                if ($("div.details p").length > 0) {
                    var refNoStr = $("div.details p").first().text().trim();
                    if (refNoStr.indexOf("Style") > -1) {
                        result.refNo = refNoStr.substring(7).trim();
                    }
                }
            }
            
            if ($('.dollars').length > 0 && $('.dollars').text().indexOf('CNY') == -1) {
                result.wrongWebSite = true;
            }
            
            if ($("#color-picker > ul > li").length > 0) {
                var colors = [];
                $("#color-picker > ul > li").each(function() {
                    var colorOption = {};
                    colorOption.title = $(this).next().val();
                    if ($(this).hasClass("selected")) {
                        colors.unshift(colorOption);
                    }else {
                        colors.push(colorOption);
                    }
                });
                
                result.colors = colors;
            }
            
            if ($("ol.selectSize li").length > 0) {
                var sizes = [];
                $("ol.selectSize li").each(function() {
                    sizes.push($(this).attr('id'));
                });
                
                result.sizes = sizes;
            }
            
            if ($('img.RICHFXColorChange').length > 0) {
                result.mainImage = $('img.RICHFXColorChange').attr('src');
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