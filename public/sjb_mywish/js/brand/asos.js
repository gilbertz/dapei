var scanIntervals=50;
function isSingleProd() {
    if ($("#ctl00_ContentMainPage_divMainContentPanel").length > 0) {
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
            return 'ASOS';
        },

        /**
         * get the current brand name
         */
        getCurrentBrandName : function() {
            return 'ASOS';
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
            if ($("#ctl00_ContentMainPage_ctlSeparateProduct_lblProductTitle").length > 0) {
                result.name = $("#ctl00_ContentMainPage_ctlSeparateProduct_lblProductTitle").text().trim();
            }
            
            if ($("#ctl00_ContentMainPage_ctlSeparateProduct_lblProductPreviousPrice").length > 0) {
                result.promotionPrice = $("#ctl00_ContentMainPage_ctlSeparateProduct_lblProductPreviousPrice").text().trim();
                if ($("#ctl00_ContentMainPage_ctlSeparateProduct_lblProductPrice").length > 0) {
                    result.oriPrice = $("#ctl00_ContentMainPage_ctlSeparateProduct_lblProductPrice").text().trim();
                }
            }else {
                if ($("#ctl00_ContentMainPage_ctlSeparateProduct_lblProductPrice").length > 0) {
                    result.oriPrice = $("#ctl00_ContentMainPage_ctlSeparateProduct_lblProductPrice").text().trim();
                }
            }
            
            if (result.oriPrice.indexOf('¥') == -1) {
                result.wrongWebSite = true;
            }
            
            if ($("#ctl00_ContentMainPage_lblInvSKU").length > 0) {
                result.refNo = $("#ctl00_ContentMainPage_lblInvSKU").text().trim();
            }
            
            if ($("#ctl00_ContentMainPage_ctlSeparateProduct_drpdwnColour option").length > 0) {
                var colors = [];
                $("#ctl00_ContentMainPage_ctlSeparateProduct_drpdwnColour option").each(function(i) {
                    if (i) {
                        var colorOption = {};
                        colorOption.title = $(this).text().trim();
                        if ("selected" == $(this).attr("selected")) {
                            colors.unshift(colorOption);
                        }else {
                            colors.push(colorOption);
                        }
                    }
                });
                
                result.colors = colors;
            }
            
            if ($("#ctl00_ContentMainPage_ctlSeparateProduct_drpdwnSize option").length > 0) {
                var sizes = [];
                $("#ctl00_ContentMainPage_ctlSeparateProduct_drpdwnSize option").each(function(i) {
                    if (i) {
                        sizes.push($(this).text().trim());
                    }
                });
                
                result.sizes = sizes;
            }
            
            if ($('#ctl00_ContentMainPage_pnlThumbImages li').length > 0) {
                $('#ctl00_ContentMainPage_pnlThumbImages li').each(function() {
                    if ($(this).find("a").hasClass("current")) {
                        var srcStr = $(this).find("a").find("img").attr('src');
                        result.mainImage = srcStr.replace("s.jpg", "xl.jpg");
                    }
                });
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
            var currency = $("#ctl00_ContentHeader_ctlTitleBar_ctlLocalisationMenu_showCurrencyList").text().trim().split(" ")[1];
            if ("RMB" == currency) {
                result.location = 'CH';
                result.currency = 'CNY';
            }else if ("EUR" == currency) {
                result.location = 'EU';
                result.currency = 'EUR';
            }else if ("USD" == currency) {
                result.location = 'US';
                result.currency = 'USD';
            }else if ("GBP" == currency) {
                result.location = 'UK';
                result.currency = 'GBP';
            }
            
            getMetaInfo(cBrand);
            _formatPrice();
            _formatTags();
            _formatResult();

            return result;
        }
    };
};