﻿    var scanIntervals=50;
    function isSingleProd() {
        var selector = 'product-listing-results';

        if (document.getElementById(selector)) {
            return false;
        } else {
            return true;
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
                return 'GAP';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'GAP';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
            getGoodImgSize : function() {
                return {
                    maxWidth: 500,
                    maxHeight: 650
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
                if ($("div.product-name > h1").length > 0) {
                    result.name = $("div.product-name > h1").first().text().trim();
                }

                if ($("#productSpecialPrice").length > 0) {
                    if ($("#productShowPrice").length > 0) {
                        result.promotionPrice = $("#productShowPrice").text().trim();
                    }
                    result.oriPrice = $("#productSpecialPrice").text().trim();
                }else {
                    if ($("#productShowPrice").length > 0) {
                        result.oriPrice = $("#productShowPrice").text().trim();
                    }
                }
                
                if ($("div.product-shop > p.availability").length > 0) {
                    result.refNo = $("div.product-shop > p.availability").first().text().replace(/[a-zA-Z.:\u4E00-\u9FA5]/g, '').trim();
                }
                if ($("#color_options_list a").length > 0) {
                    var colors = [];
                    $("#color_options_list a").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title");
                        colorOption.src = $(this).children().attr("src");
                        if ($(this).hasClass('now')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                if ($("#size_options_list p").length > 0) {
                    var sizes = [];
                    $("#size_options_list p:first a").each(function() {
                        sizes.push($(this).text());
                    });
                    
                    result.sizes = sizes;
                }
                
                if ($('#wrap img').length > 0) {
                    result.mainImage = $('#wrap img').attr("src");
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