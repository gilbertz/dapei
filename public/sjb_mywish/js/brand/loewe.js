    var scanIntervals=50;
    function isSingleProd() {
        if (document.getElementById('product') || $('div.product-view').length > 0) {
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
                return 'Loewe';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Loewe';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return false;
            },
            
            getGoodImgSize : function() {
                return {
                    maxWidth: 1000,
                    maxHeight: 1000
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
                if ($("h1.product-name").length > 0) {
                    result.name = $("h1.product-name").text().trim();
                }
                
                if ($('div.notScrolled ul').length > 0) {
                    var colors = [],
                        $colorName = $('div.property ul').find('li').first(),
                        $colorImg = $('ul.views img.prod:first'),
                        $refNo = $('div.property ul').find('li').last();
                    
                    var colorOption = {};
                    colorOption.title = $colorName.text().substring(7).trim();
                    if ($colorImg) {
                        colorOption.src = $colorImg.attr("src").replace('/image/400x/', '/thumbnail/50x/');
                    }
                    colors.push(colorOption);
                    if($("#colors ul img").length > 0) {
                        $("#colors ul img").each(function() {
                            var colorOption = {};
                            colorOption.title = ""; //$(this).attr("alt");
                            colorOption.src = $(this).attr("src");
                            colors.push(colorOption);
                        });
                    }
                    if(colors.length > 1) {
                        result.colors = colors;
                    }
                    
                    if ($refNo) {
                        result.refNo = $refNo.text().substr($refNo.text().indexOf(":") + 1).trim();
                    }
                } else {
                    var nameNode = $("div.product-main-content h2"),
                    refNode = $("span.regular-price"),
                    priceNode = $("span.regular-price .price"),
                    sizeNodes = $("select.product-custom-option option");
            
                    if (nameNode.length > 0) {
                        result.name = nameNode.text().trim();
                    }
                    
                    if (refNode.length > 0) {
                        result.refNo = refNode.attr('id').substr(refNode.attr('id').lastIndexOf('-') + 1);
                    }
                    
                    if (priceNode.length > 0) {
                        result.oriPrice = priceNode.text().trim();
                    }
                    
                    if (sizeNodes.length > 0) {
                        result.sizes = [];
                        sizeNodes.each(function(i) {
                            if (i > 0) {
                                result.sizes.push($(this).text().trim());
                             }
                        });
                    }
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