    var scanIntervals=50;
    function isSingleProd() {
        if ($("#item").length > 0) {
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
                return 'Alexander McQueen';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Alexander McQueen';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
             getGoodImgSize : function() {
                return {
                    minWidth: 300,
                    minHeight: 300
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
                if ($(".itemBoxPrice").text().indexOf('$') == -1) {
                    result.wrongWebSite = true;
                }
                
                if ($("#description h1").length > 0) {
                    result.name = $("#description h1").text().trim();
                }

                if ($(".itemBoxPrice .priceValue").length > 0) {
                    result.oriPrice = $(".itemBoxPrice .priceValue").text().trim();
                } else if ($(".itemBoxPrice .newprice").length > 0) {
                    result.oriPrice = $(".itemBoxPrice .oldprice").text().trim();
                    result.promotionPrice = $(".itemBoxPrice .newprice").text().trim();
                }
                
                if ($("#tab_description .productPropertyRow:last").length > 0) {
                    var refNo = $("#tab_description .productPropertyRow:last").text();
                    result.refNo = refNo.substr(refNo.indexOf(":") + 1).trim();
                }
                if ($("#colors .color").length > 0) {
                    var colors = [];
                    $("#colors .color").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title");
                        colorOption.src = $(this).attr("src");
                        if ($(this).parent().hasClass("selected")) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                        
                    });
                    
                    result.colors = colors;
                }
                
                if ($("#sizes span:visible").length > 0) {
                    var sizes = [];
                    $("#sizes span:visible").each(function() {
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

            var priceNum = (priceString.match(regNum)) ? priceString.match(regNum)[0] : '';
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