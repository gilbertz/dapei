    var scanIntervals=50;
    function isSingleProd() {
        if ($("#product").length > 0) {
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
                return '李宁';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return '李宁';
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
                if ($("#product_name").length > 0) {
                    result.name = $("#product_name").text().trim();
                }

                if ($("#offerPrice").length > 0) {
                    result.oriPrice = $("#offerPrice").text().trim();
                }
                if ($("#listPrice").length > 0) {
                    result.promotionPrice = $("#listPrice").text().trim();
                }
                if ($("#product_code").length > 0) {
                    result.refNo = $("#product_code").text().trim();
                }
                if ($("#thumblist li").length > 0) {
                    var colors = [];
                    $("#thumblist li").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).find('img').attr('alt');
                        colorOption.src = $(this).find('img').attr("src");
                        if ($(this).hasClass('thumbimgchecked')) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                if ($("#sizelist input").length > 0) {
                    var sizes = [];
                    $("#sizelist input").each(function() {
                        sizes.push($(this).val());
                    });
                    
                    result.sizes = sizes;
                }
                
                if ($('div.imgshowbox img').length > 0) {
                    result.mainImage = $('div.imgshowbox img').attr("src");
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