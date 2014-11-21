    var scanIntervals=50;
    function isSingleProd() {
        //giftguide: Torys-Gift-Guide/gifts-accessories
        if ($("body.pt_productdetails").length > 0 || $("body.giftguide").length > 0) {
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
                return 'Tory Burch';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Tory Burch';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return true;
            },
            
            getGoodImgSize : function() {
                return {
                    minWidth: 250,
                    minHeight: 250
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
                if ($("h1.productname").length > 0) {
                    result.name = $("h1.productname").text().trim();
                }else if ($("#breadcrumb .variationproductmodel").length > 0) {
                    result.name = $("#breadcrumb .variationproductmodel").text().trim();
                }
                if ($("#pdpTab1").length > 0) {
                    var value = $("#pdpTab1").text().trim();
                    result.refNo = value.substring(value.indexOf("Style Number: ") + "Style Number: ".length);
                } else if($("div.styleNum span").length > 0) {
                    result.refNo = $("div.styleNum span").text().trim();
                }
                
                if ($('div.productdetailcolumn div.standardprice').length > 0) {
                    result.oriPrice = $('div.productdetailcolumn div.standardprice').contents()[0].data.trim();
                    result.promotionPrice = $('div.productdetailcolumn div.salesprice').text().trim();
                } else {
                    result.oriPrice = $('div.productdetailcolumn div.salesprice').text().trim();
                }
                
                if ($("div.color a.swatchanchor").length > 0) {
                    var colors = [];
                    $("div.color a.swatchanchor").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).find('div').text().trim();
                        colorOption.src = $(this).find('img').attr("src");
                        if ($(this).parent().hasClass("selected")) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });

                    result.colors = colors;
                }
                if ($("div.size option").length > 0) {
                    var sizes = [];
                    $("div.size option").each(function(i) {
                        if (i > 0) {
                            sizes.push($(this).text().trim());
                        }
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
                result.location = 'US';
                result.currency = 'USD';
                getMetaInfo(cBrand);
                _formatTags();
                _formatResult();
                _formatPrice();

                return result;
            }
        };
    };
    