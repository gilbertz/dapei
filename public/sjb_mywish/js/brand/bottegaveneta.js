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
                return 'Bottega Veneta';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return '宝缇嘉';
            },
            
            /**
             * get if the product can be bought
             */
            getBuyOnline : function() {
                return false;
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
                /* if ($("#extra > h2").length > 0) {
                    result.name = $("#extra > h2").text().trim();
                }
                if ($("#extra > div.price > del").length > 0) {
                    result.oriPrice = $("#extra > div.price > del").text().trim();
                }
                if ($("#extra > div.itemno > span").length > 0) {
                    result.refNo = $("#extra > div.itemno > span").text().trim();
                } */
                if ($("span.customitemdescription").length > 0) {
                    result.name = $("span.customitemdescription").text().trim();
                }
                if ($("#modelFabricColor").length > 0) {
                    result.refNo = $("#modelFabricColor .mfcvalue").text().trim();
                }
                
                if($("#itemInfoBox .itemBoxPrice div.newprice").length > 0) {
                    result.promotionPrice = $("#itemInfoBox .itemBoxPrice div.newprice").text().trim();
                    if($("#itemInfoBox .itemBoxPrice div.oldprice").length > 0) {
                        result.oriPrice = $("#itemInfoBox .itemBoxPrice div.oldprice").text().trim();
                    }
                }else if ($("#itemInfoBox .itemBoxPrice").length > 0) {
                    result.oriPrice = $("#itemInfoBox .itemBoxPrice").text().trim();
                }
                
                if ($("#pageColorThumbs li").length > 0) {
                    var colors =[];
                    $("#pageColorThumbs li").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("data-selection-text");
                        
                        if ($(this).hasClass("selected")) {
                            colors.unshift(colorOption);
                        } else {
                            colors.push(colorOption);
                        }
                    });
                    
                    result.colors = colors;
                }
                
                var sizeNodes = $("#sizesUl li");
                if (sizeNodes.length > 0) {
                    var firstVal = sizeNodes.first().text().trim();
                    if(firstVal != 'OneSize'){
                        var sizes = [];
                        sizeNodes.each(function() {
                            sizes.push($(this).text());
                        });
                        result.sizes = sizes;
                    }
                }
                
                if ($("#bigImage").length > 0) {
                    result.mainImage = $("#bigImage").attr("src");
                }
            }

            function _getListProduct() {
                var container = imgNode.parentNode;
                result.name = $(container).children("span.caption").text().trim();                    
            }
            
            function _getPrice(node){
                var container = node.parentNode;
                var price=_findSubling(container);
                if(price!=''){
                    return price;
                }else if(container.parentNode){
                    return _getPrice(container);
                }
                return '';
            }

            function _findSubling(node){
                var nodes = node.childNodes;
                for(var i=0;i<nodes.length;i++){
                    if(nodes[i].nodeType==1){
                        if(nodes[i].innerHTML && nodes[i].innerHTML.indexOf("￥")!=-1){
                            return nodes[i].innerHTML.trim();
                        }
                        if(nodes[i].nodeValue && nodes[i].nodeValue.indexOf("￥")!=-1){
                            return nodes[i].nodeValue.trim();
                        }
                    }
                }
                return '';
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
            if (result.oriPrice && (result.oriPrice.indexOf("$") > -1)) {
              result.location = 'US';
              result.currency = 'USD';
            } else {
              result.location = 'CH';
              result.currency = 'CNY';
            }
            _formatPrice();
            
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
//                result.location = 'CH';
//                result.currency = 'CNY';
                getMetaInfo(cBrand);
                _formatResult();

                return result;
            }
        };
    };