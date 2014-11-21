    var scanIntervals=50;
    function isSingleProd() {
        if ($("div.product-content").length > 0) {
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
                return 'Abercrombie & Fitch';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Abercrombie & Fitch';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 498,
                    minHeight: 498,
                    maxWidth: 498,
                    maxHeight: 498
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
                if ($('div.product').length > 0) {
                    var nameArr = [],
                        oriPriceArr = [],
                        promotionPriceArr = [],
                        colorArr = [],
                        sizeArr = [],
                        refNo = '';
                    $('div.product').each(function() {
                        if ($(this).find("h1.name").length > 0) {
                            nameArr.push($(this).find("h1.name").text().trim());
                        }
                        if ($(this).find('h4.offer-price').length > 0) {
                            var priceStr = $(this).find("h4.offer-price").first().text().trim();
                            if (priceStr.indexOf('HK') == -1) {
                                result.wrongWebSite = true;
                            }
                            if (priceStr.indexOf('|') > -1) {
                                oriPriceArr.push(priceStr.replace(/HK\$/g, ''));
                            } else {
                                oriPriceArr.push(_getPriceNum(priceStr));
                            }
                        }
                        if ($(this).find('h4.list-price del').length > 0 && $(this).find('h4.list-price del').text() !='') {
                            promotionPriceArr.push(_getPriceNum($(this).find("h4.list-price del").text().trim()));
                        }
                        if ($(this).find("li.store-item-number span.number").length > 0 && !refNo) {
                            refNo = $(this).find("li.store-item-number span.number").text().trim();
                        }
                        if ($(this).find('li.color').length > 0 && !colorArr.length) {
                            var title = $(this).find('li.color').find('span').text().trim() || $(this).find('li.color').text().trim();
                            if (title.indexOf('盎司') < 0) {
                                var color = {};
                                color.title = title;
                                colorArr.push(color);
                            }
                        }
                        if ($(this).find("select.size-select option").length > 0) {
                            $(this).find("select.size-select option").each(function(i) {
                                if (i) {
                                    var sizeStr = $(this).text().trim();
                                    if (sizeStr.indexOf('盎司') > -1) {
                                        sizeStr = sizeStr.substring(0, sizeStr.indexOf('盎司') + 2).trim();
                                    }
                                    sizeArr.push(sizeStr);
                                } else if(sizeArr.length > 0) {
                                    sizeArr.push('/');
                                }
                            });
                        }
                    });
                    
                    result.oriPrice = oriPriceArr.join(' + ');
                    if (promotionPriceArr.length > 0) {
                        result.promotionPrice = promotionPriceArr.join(' + ');
                    }
                    result.name = nameArr.join(' + ');
                    result.refNo = refNo;
                    if (colorArr.length > 0) {
                        result.colors = colorArr;
                    }
                    result.sizes = sizeArr;
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
                result.location = 'HK';
                result.currency = 'HKD';
                getMetaInfo(cBrand);
                //_formatPrice();
                _formatTags();
                _formatResult();

                return result;
            }
        };
    };