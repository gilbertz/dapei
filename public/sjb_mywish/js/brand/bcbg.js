    var scanIntervals=50;
    function isSingleProd() {
        if (document.getElementById('pdpMain')) {
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
                return 'BCBG';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'BCBG';
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
                if ($("h1.product-name").length > 0) {
                    result.name = $("h1.product-name:first").text().trim();
                }
                
                if ($("#product-content > span.price-standard").length > 0) {
                    if ($("#product-content > span.price-sales").length > 0) {
                        result.promotionPrice = $("#product-content > span.price-sales:first").contents()[1].data.trim();
                    }
                    result.oriPrice = $("#product-content > span.price-standard:first").contents()[2].data.trim();
                } else {
                    if ($("#product-content span.original-price").length > 0) {
                        result.oriPrice = $("#product-content span.original-price:first").text().trim();
                    }
                }
                
                if ($('div.product-number').length > 0) {
                    result.refNo = $('div.product-number:first').text().trim();
                }
                
                if ($('div.swatches-color div.colorname').length > 0) {
                    var colors = [];
                    $('div.swatches-color div.colorname').each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).text().trim();
                        colorOption.src = $(this).find('img').attr('src');
                        if ($(this).parent().hasClass('selected')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                
                if ($('#va-size:first option').length > 0) {
                    var sizes = [];
                    $('#va-size:first option').each(function(i) {
                        if (i) {
                            sizes.push($(this).text().trim());
                        }
                    });
                    
                    result.sizes = sizes;
                }
                
                if ($('img.primary-image').length > 0) {
                    result.mainImage = $('img.primary-image').attr("src");
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
            if (priceString.indexOf('-') > -1) {
                priceNum = priceString.replace(/\$/g, '')
            } else {
                var regNum = /\d+([,，]\d+)*(\.\d+)?/;
                priceNum = priceString.match(regNum)[0];
            }
            
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