    var scanIntervals=50;
    function isSingleProd() {
        if ($("#stylenum").length > 0) {
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
                return 'Gucci';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'Gucci';
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
            if ($("#container_title_description").length > 0) {
                result.name = $("#container_title_description .container_title").text().trim();
            }else{
//                result.name = imgNode.alt || imgNode.title|| document.title;
            }
            if ($("#stylenum").length > 0) {
                result.refNo = $("#stylenum").text().trim();
            }
            
            if($("#container_variations ul.items li").length > 0) {
                var colors = [];
                $("#container_variations ul.items li").each(function() {
                    var colorOption = {};
                    colorOption.title = "";
                    colorOption.src = $(this).find("img").attr("src");
                    if($(this).hasClass("selected")) {
                        colors.unshift(colorOption);
                    }else {
                        colors.push(colorOption);
                    }
                });
                
                result.colors = colors;
            }
            
            result.tags = _getTags();
            
            function _getTags() {
                var tags = '';
                return tags;
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
                _formatTags();
                _formatResult();

                return result;
            }
        };
    };