    var scanIntervals=50;
    function isSingleProd() {
        if ($("article.product").length > 0) {
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
                return 'Prada';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Prada';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return false;
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
                if ($('section.details').find('ul').length > 0) {
                    result.name = $('section.details').find('ul').children().eq(0).text().trim();
                } else if ($("div.prod-data ul").length > 0) {
                    result.name = $("div.prod-data ul").first().text().trim();
                }
                
                if ($('section.info').find('div.code').length > 0) {
                    result.refNo = $('section.info').find('div.code').text().trim();
                } else if ($("span.code-name").length > 0) {
                    result.refNo = $("span.code-name").text().trim();
                }
                
                var colors = [],
                    origin = window.location.origin || window.location.protocol + '//' + window.location.host;
                    
                var colorOption = {};
                    colorOption.title = $("div.color .name").text().trim();
                    colorOption.src = origin + '/' + $('figure.image').children('img').first().attr('src').replace('details', 'thumbs');
                    
                colors.push(colorOption);
                    
//                if ($('figure.product').length > 0) {
//                    $('figure.product').each(function() {
//                        var colorOption = {};
//                        colorOption.title = '';
//                        colorOption.src = origin + '/' + $(this).find('img').attr('src');
//                        colors.push(colorOption);
//                    });
//                }
                
                result.colors = colors;
                // no size info
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
    
            
        /*
        *   To deal with the images with its own method.
        */
    // productBrand.isBadImage = function(img) {
        // if (img.id) {
            
        // }
    // }
