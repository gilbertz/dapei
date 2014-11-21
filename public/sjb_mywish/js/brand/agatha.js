    var scanIntervals=50;
    function isSingleProd() {
    	if(document.domain.indexOf("agatha.fr") == -1){
    		document.location.href="http://www.agatha.fr/";
    		return false;
    	}
        if ($("body.catalog-product-view").length > 0) {
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
                return 'Agatha';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Agatha';
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
            
            function _getSingleProduct() {
                if ($('div.produit-description h1').length > 0) {
                    result.name = $('div.produit-description h1').text().trim();
                }
                
                var newPrice = $("#price-block h5").contents()[0].data;
                if(newPrice && newPrice.trim()) {
                    result.promotionPrice = newPrice.trim();
                }
                
                if ($("#price-block span.price").length > 0) {
                    result.oriPrice = $("#price-block span.price").text().trim();
                }
                
                if ($("#sku").length > 0) {
                    result.refNo = $("#sku").text().trim();
                }
                
                if ($("td.champs-contenu:first img").length > 0) {
                    var colors = [];
                    $("td.champs-contenu:first img").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title");
                        colorOption.src = $(this).attr("src");
                        
                        colors.push(colorOption);
                    });
                    
                    result.colors = colors;
                }
                if ($("td.champs-contenu").length > 2) {
                    var sizes = [];
                    $("td.champs-contenu:eq(1) option").each(function(i) {
                        if(i) {
                            sizes.push($(this).text().trim());
                        }
                    });
                    
                    result.sizes = sizes;
                }
                
                if ($('#image').length > 0) {
                    result.mainImage = $('#image').attr('src').trim();
                }
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
            if(priceString.indexOf("€") > 0) {
                priceNum = priceNum.replace(",", ".");
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
            if (result.vipPrice) {
                result.vipPrice = _getPriceNum(result.vipPrice);
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
                _formatResult();
                
                return result;
            }
        };
    };