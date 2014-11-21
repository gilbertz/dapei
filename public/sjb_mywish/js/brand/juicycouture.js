    var scanIntervals=50;
    function isSingleProd() {
        if ($("#pdpMain").length > 0) {
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
                return 'Juicy Couture';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return '橘滋';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 460,
                    minHeight: 580
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
                var productNameElement = $("#pdpMain .product-name");
                if (productNameElement.length > 0) {
                    result.name = productNameElement.first().text().trim();
                }
                
                var oriPriceElement = $("#pdpMain .price-standard");
                var promoPriceElement = $("#pdpMain .price-sales");
                if(oriPriceElement.length > 0){
                    result.oriPrice = oriPriceElement.first().text().trim();
                    if(promoPriceElement.length > 0){
                        result.promotionPrice = promoPriceElement.first().text().trim();
                    }
                }else if(promoPriceElement.length > 0){
                    result.oriPrice = promoPriceElement.first().text().trim();
                }
                
                var productIdElement = $("#pdpMain .product-number span");
                if (productIdElement.length > 0) {
                    result.refNo = productIdElement.first().text().trim();
                }
                
                if ($("#pdpMain .Color li").length > 0) {
                    var colors = [];
                    $("#pdpMain .Color li").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).text().trim();
                        if ($(this).parent().hasClass("selected")) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                
                if ($("ul.va-size li").length > 0) {
                    var sizes = [];
                    $("ul.va-size li").each(function() {
                        if (!$(this).hasClass("selected")) {
                            sizes.push($(this).text().trim());
                        }
                    });
                    
                    result.sizes = sizes;
                }
                
                if ($("#izView img").length > 0) {
                    $("#izView img").each(function() {
                        if ($(this).height() > 200 && $(this).width() > 200) {
                            result.mainImage = $(this).attr("src");

                            return false;
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