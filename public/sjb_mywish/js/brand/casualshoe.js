    var scanIntervals=50;
    function isSingleProd() {
        if ($("#IndexAllWrap").length > 0 || $("div.goods-info-wrap").length > 0) {
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
                return 'Crocs';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return '卡骆驰';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
            getGoodImgSize : function() {
                return {
                    maxWidth: 749,
                    maxHeight: 749
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
                if ($("#goods-viewer .goodsname").length > 0) {
                    result.name = $("#goods-viewer .goodsname").text().trim();
                }
                if ($("#goodsBn").length > 0) {
                    result.refNo = $("#goodsBn").text().trim();
                    // result.refNo = refNo.replace(/\s{2,}/, " ");
                }
                if ($("#goods-viewer .mktprice1").length > 0) {
                    result.oriPrice = $("#goods-viewer .mktprice1").text().trim();
                    result.promotionPrice = $("#goods-viewer .goodsprice").text().trim();
                } else {
                    result.oriPrice = $("#goods-viewer .price1").text().trim();
                }
                if ($("tr.specItem img").length > 0) {
                    var colors = [];
                    $("tr.specItem img").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title");
                        colorOption.src = $(this).attr('src');
                        if ($(this).next().css('display') == 'block') {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                if ($("tr.specItem nobr").length > 0) {
                    var sizes = [];
                    $("tr.specItem nobr").each(function() {
                        sizes.push($(this).text());
                    });
                    
                    result.sizes = sizes;
                }
                
                if ($("div.goods-detail-pic img").length > 0) {
                    var srcStr = $("div.goods-detail-pic img").attr("src");
                    result.mainImage = srcStr;
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