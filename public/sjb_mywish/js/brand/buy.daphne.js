    var scanIntervals=50;
    function isSingleProd() {
        if ($("div.goods-details-wrapper").length > 0) {
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
                return '达芙妮';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return '达芙妮';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 400,
                    minHeight: 400,
                    maxWidth: 460,
                    maxHeight: 460
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
                if ($("div.goods-text h2").length > 0) {
                    result.name = $("div.goods-text h2").first().text().trim();
                }

                if ($("#price_current").length > 0) {
                    result.oriPrice = $("#price_current").text().trim();
                }
                if ($("p.mr20 b.fa").length > 0) {
                    result.promotionPrice = $("p.mr20 b.fa").text().trim();
                }
                
                if ($("ul.goods-simple-info li").length > 0) {
                    var refNoStr = $("ul.goods-simple-info li").first().text();
                    result.refNo = refNoStr.substring(refNoStr.indexOf('：') + 1).trim();
                }
                if ($("dl.choose-color dd").length > 0) {
                    var colors = [];
                    $("dl.choose-color dd").first().find("img").each(function() {
                            var colorOption = {};
                        colorOption.title = $(this).attr('alt');
                        colorOption.src = $(this).attr("src");
                        if ($(this).parent().hasClass('current')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                if ($("dl.choose-size dd").length > 0) {
                    var sizes = [];
                    $("dl.choose-size dd").first().find("a").each(function() {
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