    var scanIntervals=50;
    function isSingleProd() {
        if (document.getElementById('prdDetails')) {
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
                return 'Armani Exchange';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Armani Exchange';
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
                if ($("div.prdTxt h2").length > 0) {
                    result.name = $("div.prdTxt h2").first().text().trim();
                }
                
                if ($("#discountdPrice").length > 0) {
                    result.promotionPrice = $("#discountdPrice").first().text().trim();
                }else if($("span.pricesale_red").length > 0) {
                    result.promotionPrice = $("span.pricesale_red").first().text().trim();
                }
                
                if ($("span.pricewas").length > 0 || $('span.price').length > 0) {
                    result.oriPrice = $("span.pricewas").first().text().trim() ||$('span.price').first().text().trim() ;
                }
                
                if ($('div.prdCode').length > 0) {
                    result.refNo = $('div.prdCode').text().trim();
                }
                
                if ($("#swatchTable img").length > 0) {
                    var colors = [];
                    $("#swatchTable img").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title");
                        colorOption.src = $(this).attr("src");
                        if ($(this).hasClass('swatchSelected')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                if ($("#DetailBuyOption option").length > 0) {
                    var sizes = [];
                    $("#DetailBuyOption option").each(function(i) {
                        if (i) {
                            sizes.push($(this).text());
                        }
                    });
                    
                    result.sizes = sizes;
                }
                
                if ($('#PDPimages img').length > 0) {
                    result.mainImage = $('#PDPimages img').first().attr("src");
                }
            }

            function _getListProduct() {
                var container = imgNode.parentNode.parentNode.parentNode.parentNode;
                result.name = $(container).children("h5").children().text().trim();
                result.oriPrice = $(container).children("div.price-box").children().children().children().text().trim();            
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
            var priceString = priceString || '',
                priceNum = '';
                var regNum = /\d+([,，]\d+)*(\.\d+)?/;
                priceNum = priceString.match(regNum)[0];
            
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