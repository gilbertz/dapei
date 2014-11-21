    var scanIntervals=50;
    function isSingleProd() {
        if ($("div.ghost_lookbook").length > 0) {
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
                return 'CÉLINE';
            },

            /**
             * get the current brand name
             */
            getCurrentBrandName : function() {
                return 'CÉLINE';
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
                if ($("div.ghost_texte > p").length > 0) {
                    if ($("span.reference").length > 0) {
                        var cloneTitleNode= $("div.ghost_texte > p:first").clone();
                        cloneTitleNode.children().remove();
                        result.name = cloneTitleNode.text().replace("\n","");
                        result.refNo = $("span.reference").first().text().trim();
                    }else {
                        var datas = $("div.ghost_texte > p:first").contents(),
                            length = datas.size();
                        result.name = datas[0].data.trim();
                        result.refNo = datas[length-1].data.trim();
                    }
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