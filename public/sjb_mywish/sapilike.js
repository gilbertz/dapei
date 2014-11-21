/**
 * The entry of the function
 */
    var domains = new Array(
        "bossini",
        "etam",
        "fiveplus",
        "uniqlo",
        "zara",
        "ochirly",
        "hm",
        "gap",
        "esprit",
        "mango",
        "adidas",
        "bottegaveneta",
        "burberry",
        "celine",
        "coach",
        "armani",
        "gucci",
        "toryburch",
        "y-3store",
        "marcjacobs",
        "nikestore",
        "tommy",
        "store.prada",
        "forever21",
        "7forallmankind",
        "misssixty",
        "converse",
        "tmall",
        "balenciaga",
        "puma",
        "catfootwear",
        "alexanderwang",
        "bally",
        "casualshoe",
        "dolcegabbana",
        "tods",
        "dunhill",
        "ae",
        "longchamp",
        "store.quyeba",
        "bulgari",
        "follifollie",
        "longines",
        "omegawatches",
        "swatch",
        "swarovski",
        "buy.daphne",
        "liebo",
        "teenieweenie",
        "shop.jnby",
        "e-lining",
        "muji",
        "lachapelle",
        "anta",
        "seasonwind",
        "pb89",
        "tonlion",
        "girdear",
        "vancl",
        "mall.goelia",
        "ugg-australia",
        "store.miumiu",
        "katespade",
        "alexandermcqueen",
        "hermes",
        "dior",
        "ninewest",
        "juicycouture",
        "levi",
        "veromoda",
        "armaniexchange",
        "bcbg",
        "loewe",
        "store.valentino",
        "uggaustralia",
        "versace",
        "dkny",
        "ysl",
        "victoriassecret",
        "osa",
        "donnakaran",
        "kennethcole",
        "viviennewestwood",
        "next",
        "kenzousa",
        "store.diesel",
        "only",
        "theory",
        "jcpenney",
        "staccato-china",
        "kenzo",
        "abercrombie",
        "jcrew",
        "lanvin",
        "fendi",
        "baguette.fendi",
        "ralphlauren",
        "ferragamo",
        "anntaylor",
        "banggo",
        "stevemadden",
        "shop.ecco",
        "asos",
        "thomaspink",
        "mcmworldwide",
        "stellamccartney",
        "charleskeith",
        "shop.erke",
        "mianmayishu",
        "store.hugoboss",
        "cartier",
        "shopgeox",
        "jimmychoo",
        "peach-john",
        "agatha",
        "store.zegna",
        "c-and-a",
        "colehaan",
        "izzue",
        "shop.tadashishoji",
        "bershka",
        "michaelkors",
        "bellvilles",
        "chanel"
    );
    
    /**
     * helper function to trim the string
     */
    function trim(stringToTrim) {
        if (stringToTrim.trim) {
            return stringToTrim.trim();
        } else {
            return stringToTrim.replace(/^\s+|\s+$/g, "");
        }
    }
 (function() {

    var urlPrefix = getURLPrefix();
        // list all the iframe status
    var iframeStatus = {
        login : 'loginPage',
        show : 'showPage',
        cancel : 'originPage',
        close: 'closeIframe'
    };

    function getURLPrefix() {
        var scriptSrc = document.getElementsByTagName("script");
        scriptSrc = scriptSrc.length ? scriptSrc[scriptSrc.length - 1].src
                .toString() : "";
        var reg = /\/[a-zA-Z]+\.js/;

        return scriptSrc.replace(reg, '');
    }
    
    var frameUrl = '';
    var proxyFrameUrl = '';
    // this will reference to the ilike dom object.
    var ilike;
    // this will reference to the hidden dom object.
    var hidden;

    var Intervals = function() {
        var interval = [];
        return {
            getInterval : function() {
                return interval;
            },

            /**
             * Clear interval
             */
            clear : function() {
                for ( var i = 0; i < interval.length; i++) {
                    window.clearInterval(interval[i]);
                }
            },

            /**
             * Set interval
             */
            start : function(method, time) {
                var timer = window.setInterval(method, time);
                interval.push(timer);
            }
        };
    }();

    var promptImages = [];

    var currentDocument = window.document;

    var currentLanguage;

    var Dimension = function(width, height) {
        this.width = width;
        this.height = height;
    };
    
  imageWrapper = function () {
    var goodMinWidth = 200;
    var goodMinHeight = 200;
    var goodMaxWidth = 1500;
    var goodMaxHeight = 1500;
    var promptMinWidth = 100;
    var promptMinHeight = 100;
    var ratio = 2;

    function setSize(goodSize) {
        goodMinWidth = goodSize.minWidth || goodMinWidth;
        goodMinHeight = goodSize.minHeight || goodMinHeight;
        goodMaxWidth = goodSize.maxWidth || goodMaxWidth;
        goodMaxHeight = goodSize.maxHeight || goodMaxHeight;
    }
    
    function getNatureDimension(imgNode) {
      var dimension = null;
      
      if (imgNode.naturalWidth) {
        dimension = new Dimension(imgNode.naturalWidth, imgNode.naturalHeight);
      } else {
        /*var tmpImgNode = new Image();
        tmpImgNode.src = imgNode.src;
        var hiddenImg = hidden.childNodes[0];
        hiddenImg.src = tmpImgNode.src;*/
        dimension = new Dimension(imgNode.width, imgNode.height);
      }
      
      return dimension;
    }

    function getRatio(width, height) {
      return (width > height) ? (width / height) : (height / width);
    }

    return {
        getNatureDimension: getNatureDimension,
        setSize: setSize,
        /**
        * Check whether a image is fit our demand. Such as the dimension is bigger than 300 * 300.
        * @param {dom} imgNode An image dom object.
        */
        isGoodImage: function(imgNode) {
            var dimension = getNatureDimension(imgNode);
            var w = dimension.width || 1;
            var h = dimension.height || 1;

            //the size of the product image in swarovski is 240*240, smaller than good image min.
            if('Swarovski' == productBrand.getCurrentBrand() && w == 240 && h == 240) {
                return true;
            }

            // return (w >= goodMinWidth) && (h >= goodMinHeight) && (getRatio(w, h) <= ratio);
            // Remove ratio rule
            return (w >= goodMinWidth) && (h >= goodMinHeight) && (w <= goodMaxWidth) && (h <= goodMaxHeight);
        },

        /**
        * Check whether a image is fit our demand. Such as the dimension is bigger than 100 * 100 and smaller than 300*300.
        * @param {dom} imgNode An image dom object.
        */
        isPromptImage: function(imgNode) {
            var dimension = getNatureDimension(imgNode);
            var w = dimension.width || 1;
            var h = dimension.height || 1;

            return (w >= promptMinWidth && h >= promptMinHeight) && (w < goodMinWidth || h < goodMinHeight);
        }
    };
  }();    
    
    var Browser = function() {
        var ua = window.navigator.userAgent.toLowerCase();

        var check = function(reg) {
            return reg.test(ua);
        };

        return {
            isIE : function() {
                return check(/msie/g);
            },
            isChrome : function() {
                return check(/chrome/g);
            },
            isSafari : function() {
                return !check(/chrome/g) && check(/safari/g);
            }
        };
    }();
    
    // get the unique id of each object, if no uid, then generate one and assign to the object
    var getUID;
    (function() {
        var UID = 1;
        getUID = function(value) {
            var type = typeof (value);
            var key;
            if (type == "object" || type == "function") {
                key = value._ilikeuid;
                if (!key) {
                    key = UID++;
                    try {
                        value._ilikeuid = key;
                    } catch (ignore) {
                    }
                }
            } else {
                key = value;
            }
            return key;
        };
    })();
    
    /**
     * Cache all the attached events and manage them.
     */
    var eventMap = function() {
        var events = {};
        var sourceObjects = {};

        function getSourceObj(source) {
            if ('number' === typeof (source)) {
                return sourceObjects[source];
            } else {
                return source;
            }
        }

        return {
            /**
             * Cache a attached event.
             * 
             * @param {dom}
             *            sourceObj An dom object or object unique id.
             * @param {string}
             *            event Event name
             * @param {function}
             *            listener Event listener.
             */
            cache : function(sourceObj, event, listener) {
                var sourceUID = getUID(sourceObj);
                if (!events[sourceUID]) {
                    events[sourceUID] = {};
                }

                if (!events[sourceUID][event]) {
                    events[sourceUID][event] = {};
                }

                if (!events[sourceUID][event].listeners) {
                    events[sourceUID][event].listeners = [];
                }

                events[sourceUID][event].listeners.push(listener);
                sourceObjects[sourceUID] = sourceObj;
            },

            /**
             * Release one attached event.
             * 
             * @param {object
             *            or number} source An dom object or object unique id.
             */
            release : function(source) {
                var sourceUID = getUID(source);

                if (!events[sourceUID]) {
                    return;
                }

                for ( var event in events[sourceUID]) {
                    if (!events[sourceUID].hasOwnProperty(event)) {
                        continue;
                    }

                    var listeners = events[sourceUID][event].listeners;
                    if (listeners.constructor != Array) {
                        continue;
                    }
                    for ( var i = 0; i < listeners.length; ++i) {
                        removeDomListener(source, event, listeners[i]);
                    }
                    delete events[sourceUID][event];
                    delete sourceObjects[sourceUID];
                }
                delete events[sourceUID];
            },

            /**
             * Release all the attached events.
             */
            releaseAll : function() {
                for ( var sourceUID in sourceObjects) {
                    if (sourceObjects.hasOwnProperty(sourceUID)) {
                        this.release(sourceObjects[sourceUID]);
                    }
                }

                events = {};
                sourceObjects = {};
            }

        };
    }();

    function addDomListener(source, event, wrapper) {
        if (event == "dblclick" && Browser.isSafari()) {
            source.ondblclick = wrapper;
        } else {
            if (source.addEventListener) {
                source.addEventListener(event, wrapper, false);
            } else {
                if (source.attachEvent) {
                    source.attachEvent("on" + event, wrapper);
                } else {
                    source["on" + event] = wrapper;
                }
            }
        }
        eventMap.cache(source, event, wrapper);
    }

    function removeDomListener(source, event, wrapper) {
        if (source.removeEventListener) {
            source.removeEventListener(event, wrapper, false);
        } else {
            if (source.detachEvent) {
                source.detachEvent("on" + event, wrapper);
            } else {
                source["on" + event] = null;
            }
        }
    }

        /**
     * Communicate with Iframe.
     */
    var communication = function() {

        function sendMessageByIFrame(target, baseURL, message) {
            baseURL = baseURL.split("#")[0];
            target.src = baseURL + '#' + message;
            target.style.width = (target.offsetWidth + 1) + 'px';
        }

        function watchPostMessage() {
            addDomListener(window, 'message', handlePostMessage);
        }

        function handlePostMessage(e) {
            if (e.data) {
                onIframeStatusChange(e.data);
            }
        }

        function watchIFrameMessage() {
            Intervals.start(onHashChange, 100);
        }

        function onHashChange() {
            if (!window.location.hash || ('#' === window.location.hash)) {
                return;
            }

            var message = decodeURIComponent((window.location.href).split("#")[1]);
            onIframeStatusChange(message);
            var orig = (window.location.href).split("#")[0] + "#";

            try {
                window.location.replace(orig);
            } catch (e1) {
                window.location = orig;
            }

        }

        function onIframeStatusChange(message) {
            try {
                var messageJSON = JSON.parse(message);

                if (iframeStatus.show === messageJSON.status) {
                    ILike.updateIlikeDom(messageJSON.status, messageJSON.height);
                } else if (iframeStatus.close === messageJSON.status) {
                    closeIframe();
                }else {
                    ILike.updateIlikeDom(messageJSON.status);
                }
            } catch (e) {
                // nothing to do.
            }
        }

        return {
            postMessage : function(target, baseURL, message) {
                var targetWindow = {};
                try {
                    if (target.contentWindow) {
                        targetWindow = target.contentWindow;
                    }
                } catch (e) {
                    // nothing to do
                }
                
                if (targetWindow.postMessage) {
                    targetWindow.postMessage(message, '*');
                } else {
                    sendMessageByIFrame(target, baseURL, message);
                }
            },

            listenMessage : function() {
                if (window.postMessage) {
                    watchPostMessage();
                } else {
                    watchIFrameMessage();
                }
            }
        };
    }();

    function createNode(doc, parent, style, tag, attr) {
        node = doc.createElement(tag);
        if ('iframe' === tag) {
            node.frameBorder = 0;
            node.setAttribute('framBorder', '0');// fix IE bug,if set some
            // attribute by
            // setAttribute() after
            // appendChild,it doesn't
            // work for IE.
            node.setAttribute('scrolling', 'no');
            node.setAttribute('allowTransparency', 'true');
        }
        parent.appendChild(node);
        mergeStyle(node, style);
        return node;
    }

    function mergeStyle(node, style) {
        for (attr in style) {
            node.style[attr] = style[attr];
        }
    }

    function fillProductInfo(imgsInfo) {
        var product = Product(),
            productInfo = product.getProductInfo(),
            mainImgSrc = productInfo.mainImage,
            fisrtImg = imgsInfo[0];
        
//        console.log(productInfo);
        if (productInfo.wrongWebSite) {
            alert("Please enter into the " + productInfo.location +  " website!");
            closeIframe();
        }
        
        for (var i = 0; i < imgsInfo.length; i++) {
            if (mainImgSrc == imgsInfo[i].src) {
                imgsInfo[0] = imgsInfo[i];
                imgsInfo[i] = fisrtImg;
                break;
            }
        }
        productInfo.imgsInfo = imgsInfo;
        productInfo.domain = document.domain;
        productInfo.brandEn = productBrand.getCurrentBrand();
        //productInfo.isDetailPage = isSingleProd() ? true : false;
        
        var iframe = window.postMessage ? currentDocument.getElementById('iLikeIframe') 
                    : currentDocument.getElementById('proxyIframe');
        /* iframe.onload = function() {
            communication.postMessage(iframe, iframe.src, JSON.stringify(productInfo));
        }; */
        
        if (iframe.attachEvent){ 
            iframe.attachEvent("onload", function(){
                communication.postMessage(iframe, iframe.src, JSON.stringify(productInfo)); 
            }); 
        } else { 
            iframe.onload = function(){ 
                communication.postMessage(iframe, iframe.src, JSON.stringify(productInfo));
            }; 
        }
    }

    function Point(x, y) {
        this.x = x;
        this.y = y;
    }

    function getIFrameDocument(id) {
        return document.getElementById(id).contentDocument
                || document.frames[id].document;
    }

    function getIFrameWindow(id) {
        return document.getElementById(id).contentWindow || document.frames[id];
    }

    // Handle close popup window.
    function closeIframe() {
        currentDocument.body.removeChild(ilike);
        currentDocument.body.removeChild(hidden);
        Intervals.clear();
        eventMap.releaseAll();
        
        if (window.origin$) {
            $ = origin$;
        }
        if (window.$jQuery$) {
            jQuery = window.$jQuery$;
        }
    }
        /**
     * Create iLike window.
     */
    var ILike = function() {

        var bgImg = urlPrefix + '/images/bg_sprites.png';
        var ilikeBody = '';
        var iLikeStatus = '';
        var iframeHeight = 0;

        /**
         * Create window of iLike
         */
        function createIlike() {
            var isIEQuirks = Browser.isIE() && (document.compatMode == 'BackCompat'); //strict comatMode: 'CSS1Compat'
            var style = {
                display : 'block',
                width : '100%',
                height : '100%',
                position : isIEQuirks ? 'absolute' : 'fixed',
                top : '0px',
                left : '0px',
                zIndex : 10000002,
                overflow : 'hidden'
            };
            ilike = createNode(currentDocument, currentDocument.body, style,
                    'div');
            ilike.id = 'ilike';
            
            if (isIEQuirks) {
                window.onresize = window.onscroll = function() {
                    ilike.style.top = (document.body.scrollTop || document.documentElement.scrollTop) + 'px';
                }
            }
        }

        /**
         * Create iframe in iLike.
         */
        function createIframe() {
            var iframeStyle = {
                display : 'block',
                width : '100%',
                overflow : 'hidden',
                height : '100%',
                maxWidth : '100%',
                maxHeight : '100%',
                border : 'none',
                background : 'transparent'
            };
            var iframe = createNode(currentDocument, ilike, iframeStyle,
                    'iframe');
            iframe.id = 'iLikeIframe';
            iframe.name = 'iLikeIframe';
            iframe.src = frameUrl;
            iframe.charset = "UTF-8";
        }

        /**
         * Create a hidden iframe in iLike.
         */
        function createProxyIframe() {
            var iframeStyle = {
                position : 'absolute',
                top : '-1000px',
                right : '-1000px'
            };
            var proxyIframe = createNode(currentDocument, ilike, iframeStyle,
                    'iframe');
            proxyIframe.id = 'proxyIframe';
            proxyIframe.src = proxyFrameUrl;
        }

        return {
            init : function() {
                createIlike();
                createIframe();
                createProxyIframe();
            }
        };
    }();

    //iframe: the jQuery object of the iframe, when the product detail page is in an iframe 
    function scan(iframe) {
        var nodes = null, goodImages = [];
        if(iframe) {
            nodes = iframe[0].contentWindow.document.getElementsByTagName('img');
        }else {
            nodes = document.body.getElementsByTagName('img');
        }
        
        var img;
        if (productBrand.getGoodImgSize) {
            imageWrapper.setSize(productBrand.getGoodImgSize());
        }
        
        for ( var i = 0; i < nodes.length; ++i) {
            img = nodes[i];
            if(img.src == ''){
            	continue;
            }
            if (imageWrapper.isGoodImage(img) && !imgIsInGoodImage(img)) {
                var imgInfo = imageWrapper.getNatureDimension(img);
                imgInfo.src = img.src;
            
                goodImages.push(imgInfo);
            } else if (imageWrapper.isPromptImage(img) && !imgIsInPromptImage(img)) {
                promptImages.push(img.src);
            }
        }
        function imgIsInGoodImage(img) {
            for ( var j = 0; j < goodImages.length; j++) {
                if (img.src == goodImages[j].src) {
                    return true;
                    break;
                }
            }
            return false;
        }

        function imgIsInPromptImage(img) {
            for ( var j = 0; j < promptImages.length; j++) {
                if (img == promptImages[j]) {
                    return true;
                    break;
                }
            }
            return false;
        }
        
        if (goodImages.length > 0) {
            ilike = currentDocument.getElementById('ilike');
            if (!ilike) {
                ILike.init();
            }
            communication.listenMessage();
            fillProductInfo(goodImages);
        } else {
            currentDocument.body.removeChild(hidden);
            if (window.origin$) {
                $ = origin$;
            }
            if (window.$jQuery$) {
                jQuery = window.$jQuery$;
            }
            //杩欎釜椤甸潰涓婄殑鍥炬棤娉曡幏鍙栵紝鍘诲晢鍝佽鎯呴〉闈㈠啀璇曡瘯鍚э紒
            alert("杩欎釜椤甸潰涓婄殑鍥炬棤娉曡幏鍙栵紝鍘诲晢鍝佽鎯呴〉闈㈠啀璇曡瘯鍚э紒");
        }
    }

    /**
     * Initialize the language environment, it's useful when change different
     * language bookmarklet.
     */
    function initLanguage() {
        currentLanguage = top.iLikeLang || 'zh-CN';
        frameUrl = urlPrefix + '/iframe.html?lang=' + currentLanguage + '&ref='
                + encodeURIComponent(window.location);
        proxyFrameUrl = urlPrefix + '/proxyiframe.html?ref='
                + encodeURIComponent(window.location);
    }

    // Create a 1x1px element to append temp image object
    function createHiddenElement() {
        hidden = createNode(currentDocument, currentDocument.body, {
            overflow : 'hidden',
            position : 'absolute',
            width : '1px',
            height : '1px'
        }, 'div');
        createNode(currentDocument, hidden, {}, 'img');
    }
    
    function initCommonFunc() {
        scriptURL = urlPrefix +"/js/common.js";

        $.ajax({
            url: scriptURL,
            dataType: "script",
            async: false,
            success: function(){
                createHiddenElement();
                
                if(typeof(isSingleProd()) != 'boolean') {
                    scan(isSingleProd());
                }else {
                    scan();
                }
            }
        });
    }
    
    function init() {
        initLanguage();
        initCommonFunc();
    }
    
    function getBrandScript() {
        if(document.domain.indexOf("shoperke") > -1) {
            return "shop.erke";
        }
        
        for(var i=0;i<domains.length;i++){
            var regStr = '(\\.|^)' + domains[i] + '\\.';
            var reg = new RegExp(regStr);
            if(reg.test(document.domain)){
                return domains[i];
            }
        }
        return null;
    }
    
    var brandScript = getBrandScript();
    var scriptURL;
    if(brandScript){
        scriptURL = urlPrefix +"/js/brand/" + brandScript + ".js";
    }else{
        scriptURL = urlPrefix +"/js/" + "default.js";
    }
    
    setTimeout(function(){
        if(jQuery) {        
            $.ajax({
                url: scriptURL,
                dataType: "script",
                scriptCharset: "UTF-8",
                success: function(){
                    window.sapiLike = {};
                    sapiLike.jQuery = $;
                    window.sapiLike.run = init;
                    init();
                }
            });
        }else {
            setTimeout(arguments.callee, 10);
        }
    }, 10);
}());