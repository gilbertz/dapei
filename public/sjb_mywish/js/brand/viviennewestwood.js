    var scanIntervals=50;
    function isSingleProd() {
        if ($("div.item").length > 0) {
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
                return 'Vivienne Westwood';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Vivienne Westwood';
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
                if ($("#product_detail h1").length > 0) {
                    result.name = $("#product_detail h1").first().text().trim();
                }
                
                if ($("#product_detail span.was-price").length > 0) {
                    result.promotionPrice = $("#product_detail span.was-price").text().trim();
                    if ($("#product_detail span.now-price").length > 0) {
                        result.oriPrice = $("#product_detail span.now-price").text().trim();
                    }
                } else {
                    if ($('#product_detail span.price').length > 0) {
                        result.oriPrice = $("#product_detail span.price").text().trim();
                    }
                }
                
                if (result.oriPrice.indexOf('£') == -1) {
                    result.wrongWebSite = true;
                }
                
                if ($("#product-details p.product-id").length > 0) {
                    var refNoStr = $("#product-details p.product-id").text().trim();
                    result.refNo = refNoStr.substring(5).trim();
                }
                
                if ($('#att_Size option').length > 0) {
                    var sizes = [];
                    $("#att_Size option").each(function() {
                            sizes.push($(this).text().trim());
                    });
                    
                    result.sizes = sizes;
                } else if ($("div.attributes div.att").length > 1) {
                    var sizes = [];
                    sizes.push($("div.attributes div.att").eq(1).text().trim().substring(5).trim());
                    
                    result.sizes = sizes;
                }
                
                if ($('#gallery-images li').length > 0) {
                    $('#gallery-images li').each(function() {
                        if ($(this).css('margin-left') == '0px') {
                            result.mainImage =  $(this).find('img:first').attr('src');
                            return;
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
                result.location = 'UK';
                result.currency = 'GBP';
                getMetaInfo(cBrand);
                _formatPrice();
                _formatTags();
                _formatResult();

                return result;
            }
        };
    };