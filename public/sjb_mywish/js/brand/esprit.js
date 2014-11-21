    var scanIntervals=50;
    function isSingleProd() {
        if ($("div.detail").length > 0) {
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
                return 'Esprit';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Esprit';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 330,
                    minHeight: 495
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
                if ($(".textInfo > h3").length > 0) {
                    result.name = $(".textInfo > h3").text().trim();
                }

                if ($(".sku_price3 > h4 > .grey_lt").length > 0) {
                    result.oriPrice = $(".sku_price3 > h4 > .grey_lt").text().trim();
                } else {
                    result.oriPrice = $(".sku_price3 > h4 > span").text().trim();
                }
                if ($(".sku_price3 > h4 > .red").length > 0) {
                    result.promotionPrice = $(".sku_price3 > h4 > .red").text().trim();
                }
                if ($("#goods > .parameters > span").length > 0) {
                    result.refNo = $("#goods > .parameters > span").first().text().trim();
                }
                if ($("div.sku_color2 a").length > 0) {
                    var colors = [];
                    $("div.sku_color2 a").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title");
                        colorOption.src = $(this).find('img').attr('src');
                        if ($(this).hasClass('hover')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                if ($("dl.es_new_size dd").length > 0) {
                    var sizes = [];
                    $("dl.es_new_size dd").each(function() {
                        sizes.push($(this).text());
                    });
                    
                    result.sizes = sizes;
                }
                
                if ($('div.skupic_m').children().last().find('img').length > 0) {
                    result.mainImage = $('div.skupic_m').children().last().find('img').attr('src');
                }
                
            }

            function _getListProduct() {
                var container = imgNode.parentNode.parentNode.parentNode;
                result.name = $(container).children("div.sku_title").children().children().text().trim();
                result.oriPrice = $(container).children("div.sku_price").children().children().text().trim();                        
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