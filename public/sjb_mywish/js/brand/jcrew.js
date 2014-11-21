    var scanIntervals=50;
    function isSingleProd() {
        if ($("#singlePDP").length > 0) {
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
                return 'J Crew';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'J Crew';
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
                var nameNode = $("section.description header h1"),
                refNode = $("section.description header span.item-num"),
                priceNode = $("div.full-price"),
                promotionNode = $("div.price-wrapper div.product-detail-price"),
                colorNodes = $("div.color-box"),
                sizeNodes = $("div.size-box");
                
                /* if ($("div.pdp-shapes .pdp-radio input[checked]").length > 0) {
                    var item = $("div.pdp-shapes .pdp-radio input[checked]").parent().next();
                    refNode = item.find(".itemid");
                    
                    if (item.find(".price").length > 0) {
                        result.oriPrice = item.find(".price").text().trim();
                    }
                    if (item.find(".select-sale").length > 0) {
                        var promotionPrice = item.find(".select-sale").text().trim();
                        result.promotionPrice = promotionPrice;
                    }
                } */
                
                if (nameNode.length > 0) {
                    result.name = nameNode.text().trim();
                }/* else{
                    nameNode = $(".producttitle");
                    if (nameNode.length > 0) {
                        result.name = nameNode.text().trim();
                    }
                } */

                if (refNode.length > 0) {
                    var refVal = refNode.text().trim();
                    result.refNo = refVal.substr(5).trim();
                }/* else{
                    refNode = $("td.standard");
                    if (refNode.length == 2) {
                        var refVal = refNode.eq(1).text().trim();
                        var refPos = refVal.indexOf("Item");
                        if(refPos > -1){
                            result.refNo = refVal.substr(refPos + 4).trim();
                        }
                    }
                } */
                
                if (promotionNode.length > 0) {
                    if (priceNode.find("span.price-soldout").length > 0) {
                        result.oriPrice = priceNode.find("span.price-soldout").text().trim();
                    }
                }else if(priceNode.length > 0) {
                    result.oriPrice = priceNode.find("span:first").text().trim();
                }else if($("input.product-details-variants:checked").parent().parent().find("span.full-price").length > 0) {
                    result.oriPrice = $("input.product-details-variants:checked").parent().parent().find("span.full-price").text().trim();
                }

                if (colorNodes.length > 0) {
                    var colors = [];
                    colorNodes.each(function() {
                        var colorOption = {};
                        colorOption.title = "";
                        colorOption.src = $(this).find("img").attr("src");
                        if ($(this).hasClass("selected")) {
                            colors.unshift(colorOption);
                            result.promotionPrice = $(this).parent().prev().text().trim();
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                
                if (sizeNodes.length > 0) {
                    var sizes = [];
                    sizeNodes.each(function() {
                        sizes.push($(this).attr("data-size"));
                    });
                    
                    result.sizes = sizes;
                }
                
                if(result.oriPrice) {
                    
                }
                
                if ($("#top_nav_country").text().indexOf("China") == -1) {
                    result.wrongWebSite = true;
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