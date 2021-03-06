﻿    var scanIntervals=50;
    function isSingleProd() {
        if ($("#descriptionPanel").length > 0) {
            return true;
        } else {
            return false;
        }
    }
    /**
     * Object, supported sites collections with brand names
     */
    var productBrand = function() {
        var brand = 'Armani',
        brandName = 'Armani',
        href = location.href;

        
        if (href.indexOf('armanijeans') > -1) {
            brand = "Armani Jeans";
            brandName = "Armani Jeans";
        } else if (href.indexOf('emporioarmani') > -1) {
            brand = "Emporio Armani";
            brandName = "Emporio Armani";
        } else if (href.indexOf('giorgioarmani') > -1) {
            brand = "Giorgio Armani";
            brandName = "Giorgio Armani";            
        }
        
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
                return brand;
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return brandName;
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
                    minHeight: 500,
                    maxWidth: 500,
                    maxHeight: 555
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
                if ($("#catTitle").length > 0) {
                    result.name = $("#catTitle").text().trim();
                }
                
                if($("#cartBox > div.prodPrice > span.newprice").length > 0) {
                    result.promotionPrice = $("#cartBox > div.prodPrice > span.newprice").text().trim();
                    if($("#cartBox > div.prodPrice > span.sconto").length > 0) {
                        result.oriPrice = $("#cartBox > div.prodPrice > span.sconto").text().trim();
                    }
                }else if ($("#cartBox > div.prodPrice > span").length == 1) {
                    result.oriPrice = $("#cartBox > div.prodPrice > span").text().trim();
                }
                
                if ($("#mfc").length > 0) {
                    result.refNo = $("#mfc").text().trim();
                }
                if ($("#colorsBoxContainer div.colorBox").length > 0) {
                    var colors = [];
                    $("#colorsBoxContainer div.colorBox").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title");
                        colorOption.value = $(this).children().css('background-color');
                        if ($(this).hasClass('selected')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                if ($("#sizesContainer .sizeBoxIn").length > 0) {
                    var sizes = [];
                    $("#sizesContainer .sizeBoxIn").each(function() {
                        sizes.push($(this).text());
                    });
                    
                    result.sizes = sizes;
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