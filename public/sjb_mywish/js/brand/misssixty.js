    var scanIntervals=50;
    function isSingleProd() {
        if ($("div.GoodsInfoWarp").length > 0) {
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
                return 'Miss Sixty';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Miss Sixty';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return false;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 590,
                    minHeight: 765,
                    maxWidth: 5000,
                    maxHeight: 5000
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
                if ($("h2.writ_tit").length > 0) {
                    result.name = $("h2.writ_tit").text().trim();
                }

                if ($("#FORM_GOODS_ID").length > 0) {
                    result.refNo = $("#FORM_GOODS_ID").val();
                }
                
                if ($("#newprice").length > 0) {
                    result.oriPrice = $("#newprice").text().trim();
                }
                /* if ($(".product-id").length > 0) {
                    result.refNo = $(".product-id").text().trim();
                } */
                
                if ($('ul.pro_size li').length > 0) {
                    var sizes = [];
                    $('ul.pro_size li').each(function() {
                        sizes.push($(this).find('label').text());
                    });
                    
                    result.sizes = sizes;
                }
            }

            function _getListProduct() {
                result.name = imgNode.alt || imgNode.title|| document.title;
            }
            
            function _getTags() {
                var tags = '';
                if($("table.subinfo").length > 0) {
                    tags = $("table.subinfo tr")[1].children[0].innerHTML.trim();
                }
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