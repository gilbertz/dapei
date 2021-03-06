﻿    var scanIntervals=50;
    function isSingleProd() {
        if ($("div.detail_box").length > 0) {
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
                return '欧时力';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return '欧时力';
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
                if ($("div.pro_info h2").length > 0) {
                    result.name = $("div.pro_info h2:first").contents()[0].data.trim();
                    result.refNo = $("div.pro_info h2:first em").text().trim();
                }

                if ($("#proPriceNum").length > 0) {
                    if ($("#proPriceNum").find('em').length > 0 && $("#proPriceNum").find('em').text().indexOf('折') == -1) {
                        result.oriPrice = $("#proPriceNum").find('em del').text().trim();
                        result.promotionPrice = $("#proPriceNum").find('em').contents()[2].data;
                    } else {
                        result.oriPrice = $("#proPriceNum").contents()[0].data.trim();
                    }
                }
                
                if ($("#proColor img").length > 0) {
                    var colors = [];
                    $("#proColor img").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr('alt');
                        colorOption.src = $(this).attr('src');
                        
                        if ($(this).parents('span').length > 0) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                
                if ($("#groupChooseSize a").length > 0) {
                    var sizes = [];
                    $("#groupChooseSize a").each(function() {
//                        if (!$(this).hasClass("btn_size_dis")) {
                            sizes.push($(this).text());
//                        }
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