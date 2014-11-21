    var scanIntervals=50;
    function isSingleProd() {
        if ($("body.product").length > 0) {
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
                return 'JIMMY CHOO';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'JIMMY CHOO';
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
            
            function _getSingleProduct() {
                if ($("div.pdright h1").length > 0) {
                    result.name = $("div.pdright h1").text().trim();
                }

                var priceNode = $("span.product-price");
                if (priceNode.length > 0) {
                    result.refNo = priceNode.attr("id").substring(9);
                    if(priceNode.find("span.wasprice").length > 0) {
                        result.oriPrice = priceNode.find("span.wasprice").text().trim();
                        result.promotionPrice = priceNode.contents()[3].data.trim();
                    }else {
                        result.oriPrice = priceNode.text().trim();
                    }
                }
                
                if ($("div.alternative-colours li").length > 0) {
                    var colors = [];
                    $("div.alternative-colours li").each(function() {
                        var colorOption = {};
                        colorOption.title = "";
                        colorOption.src = $(this).find("img").attr("src");
                        if ($(this).hasClass("colour-selected")) {
                            colors.unshift(colorOption);
                        }else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                
                var sizesNode = $("div.invtatr select[name=att2] option");
                if (sizesNode.length > 0) {
                    var sizes = [];
                    sizesNode.each(function(i) {
                        if (i>0) {
                            sizes.push($(this).text());
                        }
                    });
                    
                    result.sizes = sizes;
                }    
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
            if (result.vipPrice) {
                result.vipPrice = _getPriceNum(result.vipPrice);
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
                _formatResult();
                
                return result;
            }
        };
    };