    var scanIntervals=50;
    function isSingleProd() {
        var selector = 'iteradorPrendas';

        if (document.getElementById(selector)) {
            return false;
        } else {
            return true;
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
                return 'Mango';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Mango';
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
                if ($("div.nombreProducto").length > 0) {
                    result.name = $("div.nombreProducto").first().text().trim().replace("--", "");
                }
                
                if ($("div.precioProducto").length > 0) {
                	var priceStr = $("div.precioProducto").text().trim();
                	if(priceStr.indexOf("(")!=-1){
                		priceStr = priceStr.substring(0, priceStr.indexOf("(")).trim();
                	}
                	
                	var priceIndex = priceStr.lastIndexOf("$");
                	if( priceIndex> 0){
                		result.promotionPrice = priceStr.substring(priceIndex).trim();
                		result.oriPrice = priceStr.substring(0, priceIndex).trim();
                	}else{
                		result.oriPrice = priceStr;
                	}
                }
                
                var refNode = $("div.referenciaProducto");
                if (refNode.length > 0) {
                    var refNoStr = refNode.first().text().trim();
                    result.refNo = refNoStr.substring(refNoStr.indexOf('.') + 1, refNoStr.indexOf('-')).trim();
                }
                var container = document.getElementById("Form:bodyContent");
                //result.tags = $(container).children().eq(1).children().children().children().eq(1).children().children().children().children().children().children().children().eq(1).children().eq(1).text().replaceALL('>', '&&').replaceALL('\n', '');
                result.tags = "";
                
                var colorDom = document.getElementById("Form:SVFichaProducto:ficha_colores");
                var sizeDom = $("#listaTallas select option");
                if (colorDom) {
                    var colors = [];
                    $(colorDom).find("div._color_div_on img.color_img_on").each(function() {
                        var colorOption = {};
                        colorOption.title = $(this).attr("title").trim();
                        colorOption.src = $(this).attr("src");
                    });
                    
                    result.colors = colors;
                }
                if (sizeDom) {
                    var sizes = [];
                    sizeDom.each(function() {
                    	if($(this).attr("name") == 'true'){
                    		sizes.push($(this).text().trim());
                    	}
                    });
                    
                    result.sizes = sizes;
                }      
            }

            function _getListProduct() {
                var container = imgNode.parentNode.parentNode.parentNode.parentNode.parentNode;
                result.oriPrice = $(container).children().last().children().first().children().first().children().first().children().first().children().eq(2).children().children().text().trim();
                result.name = $(container).children().last().children().first().children().first().children().first().children().first().children().eq(1).children().children().text().trim();    
                var nar=document.getElementById("Form:SVBusc:SVBusc_3:barraNavegacion");
                result.tags = $(nar).text().replace('>', '&&');
            }
            
            function _getTags() {
                var tags = '';
                /*
                if ($("a > span.txt7").length > 0) {
                    tags = $("a > span.txt7").last().text().trim();
                }
                */
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
                            'name' : newTags[i].trim()
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