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
                return 'Alexander Wang';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return '亚历山大·王';
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
                if ($("#itemInfoBox h1 span").length > 0) {
                    result.name = $("#itemInfoBox h1 span:first").text().trim();
                }
                if ($("#itemStyle").length > 0) {
                    var refNo = $("#itemStyle").text().trim();
                    result.refNo = refNo.substr(refNo.indexOf(":") + 2);
                }
                if ($("#itemInfoBox .itemBoxPrice").length > 0) {
                    if ($('div.oldprice').length > 0) {
                        result.promotionPrice = $('div.oldprice').text().trim();
                    }
                    if ($('div.newprice').length > 0) {
                        result.oriPrice = $('div.newprice').text().trim();
                        return;
                    }
                    result.oriPrice = $("#itemInfoBox .itemBoxPrice").text().trim();
                }
                
                if ($("#sizesUl li").length > 0) {
                    var sizes = [];
                    $("#sizesUl li").each(function() {
                        sizes.push($(this).text());
                    });
                    
                    result.sizes = sizes;
                }
            }

            function _getListProduct() {
                var container = imgNode.parentNode;
                result.name = $(container).children("div.productinfo").children(".product-name").text().trim();
                result.oriPrice = $(container).children("div.productinfo").children(".prodPrice").children().text().trim();                
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