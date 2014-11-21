    var scanIntervals=50;
    function isSingleProd() {
        if ($("div.pt_productdetails").length > 0) {
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
                return 'Only';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Only';
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
                if ($("h1.productname").length > 0) {
                    result.name = $("h1.productname").text().trim();
                }
                
                if ($('div.product_info span.price_value').length > 0) {
                    result.oriPrice = $('div.product_info span.price_value').text().trim();
                }
                
                if ($("div.product_info div.standard_price").length > 0) {
                    result.promotionPrice = $("div.product_info div.standard_price").text().trim();
                }
                
                if ($("div.product_style").length > 0) {
                    var refNoStr = $('div.product_style').text().trim();
                    result.refNo = refNoStr.substring(6, refNoStr.indexOf('EAN')).trim();
                }
                
                if ($('div.colorPattern li').length > 0) {
                    var colors = [];
                    $('div.colorPattern li').each(function() {
                        var colorOption = {},
                            srcStr = $(this).css('background-image');
                        colorOption.title = $(this).next().text().trim();
                        colorOption.src = srcStr.substring(srcStr.indexOf('(') + 1, srcStr.indexOf(')')).replace('"', '');
                        if ($(this).hasClass('selected')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                
                if ($("div.size li").length > 0) {
                    var sizes = [];
                    $("div.size li").each(function() {
                        sizes.push($(this).text().trim());
                    });
                    
                    result.sizes = sizes;
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
                result.location = 'EU';
                result.currency = 'EUR';
                getMetaInfo(cBrand);
                _formatPrice();
                _formatTags();
                _formatResult();

                return result;
            }
        };
    };