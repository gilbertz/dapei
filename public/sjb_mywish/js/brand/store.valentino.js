    var scanIntervals=50;
    function isSingleProd() {
        if (document.getElementById('item')) {
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
                return 'Valentino';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Valentino';
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
                if ($("span.titleDetailItem").length > 0) {
                    result.name = $("span.titleDetailItem").first().text().trim();
                }
                if (jsoninit_itemsnavigation) {
                    result.refNo = jsoninit_itemsnavigation.COD10;    
                }
                
                if($('div.itemBoxPrice div.newprice').length > 0) {
                    result.promotionPrice = $('div.itemBoxPrice div.newprice').text().trim();
                    if($('div.itemBoxPrice div.oldprice').length > 0) {
                        result.oriPrice = $('div.itemBoxPrice div.oldprice').text().trim();
                    }
                }else if ($('div.itemBoxPrice').length > 0) {
                    result.oriPrice = $('div.itemBoxPrice').text().trim();
                }
                
                if (result.oriPrice.indexOf('€') == -1) {
                    result.wrongWebSite = true;
                }
                
                if ($('#colorsContainer div.colorBoxSelected').length > 0) {
                    var colors = [],
                        colorOption = {};
                    colorOption.title = $('#colorsContainer div.colorBoxSelected').attr('title').trim();
                    colors.push(colorOption);
                    
                    result.colors = colors;
                }
                
                if ($('#listOfSz li.sizeBox').length > 0) {
                    var sizes = [];
                    $('#listOfSz li.sizeBox').each(function() {
                        sizes.push($(this).text());
                    });
                    
                    result.sizes = sizes;
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
                result.location = 'EU';
                result.currency = 'EUR';
                getMetaInfo(cBrand);
                _formatPrice();
                _formatTags();
                _formatResult();

                return result;
            }
        };
    };