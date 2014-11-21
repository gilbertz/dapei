/**
 * Common functions
 */
 
var GLOBAL = {};

GLOBAL.URL = {
  getURLParameter: function(name) {
    return decodeURIComponent(
      (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
    );
  },

  getUrlByDomain: function(url) {
    var domain = location.protocol + "//" + location.host;
    return domain + url;
  }
};

/**
 * Handle local data. If browser supports HTML5 storage, data will handle by HTML5 storage, else by cookie.
 */
GLOBAL.storage = {
  /**
   * Set an item value into HTML5 storage or cookie
   * @param {string} key The key to set value.
   * @param {string} value The value to set.
   * @param {string} isSession Whether get a sessionStorage value or a localStorage value.
   */
  saveItem: function(key, value, isSession) {
    if (this._isSupportStorage()) {
      this._saveItemIntoStorage(key, value, isSession);
    } else {
      this._saveItemIntoCookie(key, value, isSession);
    }
  },
  
  /**
   * Get an item value from HTML5 storage or cookie
   * @param {string} key The key to get value.
   * @param {string} isSession Whether get a sessionStorage value or a localStorage value.
   * @return {string} The value.
   */
  getItem: function(key, isSession) {
    var value;
    
    if (this._isSupportStorage()) {
      value = this._getItemFromStorage(key, isSession);
    } else {
      value = this._getItemFromCookie(key, isSession);
    }
    
    return value;
  },
  
  //Save data into HTML5 storage.
  _saveItemIntoStorage: function(key, value, isSession) {
    if (isSession) {
      sessionStorage[key] = value;
    } else {
      localStorage[key] = value;
    }
  },
  
  _saveItemIntoCookie: function(key, value, isSession) {
    if (isSession) {
      document.cookie = key + '=' + escape(value) + ';';
    } else {
      var expireDate = new Date(3011, 11, 30);
      document.cookie = key + '=' + escape(value) + ';expires=' + expireDate.toGMTString();
    }
  },
  
  _getItemFromStorage: function(key, isSession) {
    var value;
    
    if (isSession) {
      value = sessionStorage[key];
    } else {
      value = localStorage[key];
    }
    
    return value;
  },
  
  _getItemFromCookie: function(key) {
    var cookieString = document.cookie;
    var first = cookieString.indexOf(key + '=');
    
    if (first >= 0) {
      var str = cookieString.substring(first, cookieString.length);
      var last = str.indexOf(';');
      if (last < 0) {
        last = str.length;
      }
      str = str.substring(0, last).split('=');
      return unescape(str[1]);
    } else {
      return null;
    }
  },
  
  //Check whether support HTML5 storage
  _isSupportStorage: function() {
    return window.localStorage ? true : false;
  }
};

/**
 * helper function to trim the string
 * @param {String}  stringToTrim  The string need to be trimed.  
 */
GLOBAL.trim = function(stringToTrim) {
  if (stringToTrim.trim) {
    return stringToTrim.trim();
  } else {
    return stringToTrim.replace(/^\s+|\s+$/g, "");
  }
}

GLOBAL.addClass = function (ele, cls) {
  // function _hasClass(ele,cls) {
    // return ele.className.match(new RegExp('(\\s|^)'+cls+'(\\s|$)'));
  // }

  // function _addClass(ele,cls) {
    // if (!_hasClass(ele,cls)) {
      // ele.className += " "+cls;
    // }
  // }
  
  // _addClass(ele,cls);
}

/**
 * Get specified length substring
 * @param {string} The string need to intercept
 * @param {number} The wanted lenght of string as english character
 */
GLOBAL.getInterceptedStr = function(sSource, iLen, replacer) {
  if(sSource.replace(/[^\x00-\xff]/g, "xx").length <= iLen) {  
    return sSource;
  }  

  var str = "";  
  var l = 0;  
  var schar;  
  for(var i = 0; schar = sSource.charAt(i); i++) {  
    str += schar;
    l += (schar.match(/[^\x00-\xff]/) != null ? 2 : 1);
    if(l >= iLen) {
      break;
    }
  }

  return str + replacer;
}

/**
 * Add and remove event handler
 */
GLOBAL.listener = {
  addDomListener: function(source, event, wrapper) {
    if (event == "dblclick" && Browser.isSafari) {
      source.ondblclick = wrapper
    } else {
      if (source.addEventListener) {
        source.addEventListener(event, wrapper, false)
      } else {
        if (source.attachEvent) {
          source.attachEvent("on" + event, wrapper)
        } else {
          source["on" + event] = wrapper
        }
      }
    }
  },

  removeDomListener: function(source, event, wrapper) {
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
};

/**
 * Param format string data convert.
 */
GLOBAL.Param = {
  getParamsFromStr: function(strParam) {
    var strVals = strParam.split("&");
    var result = {};
    for (var i = 0; i < strVals.length; i++) {
      var value = strVals[i].split("=");
      result[value[0]] = value[1];
    }
    
    return result;
  }
};

/**
 * Convert img to data source
 */
GLOBAL.ImageConvert = {
    /**
     * Convert img to data source
     * @param img: img dom element.
     */
    getBase64Image: function (img) {
        // Create an empty canvas element
        var canvas = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;

        // Copy the image contents to the canvas
        var ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);

        // Get the data-URL formatted image
        // Firefox supports PNG and JPEG. You could check img.src to
        // guess the original format, but be aware the using "image/jpg"
        // will re-encode the image.
        var dataURL = canvas.toDataURL("image/png");

        return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
    }
}

if(!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/g,'');
    };
}

/**
 * JSON2 plugin
 */
var JSON;
if (!JSON) {
    JSON = {};
}

(function () {
    "use strict";

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf()) ?
                this.getUTCFullYear()     + '-' +
                f(this.getUTCMonth() + 1) + '-' +
                f(this.getUTCDate())      + 'T' +
                f(this.getUTCHours())     + ':' +
                f(this.getUTCMinutes())   + ':' +
                f(this.getUTCSeconds())   + 'Z' : null;
        };

        String.prototype.toJSON      =
            Number.prototype.toJSON  =
            Boolean.prototype.toJSON = function (key) {
                return this.valueOf();
            };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

        escapable.lastIndex = 0;
        return escapable.test(string) ? '"' + string.replace(escapable, function (a) {
            var c = meta[a];
            return typeof c === 'string' ? c :
                '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
        }) + '"' : '"' + string + '"';
    }


    function str(key, holder) {

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return 'null';
            }

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0 ? '[]' : gap ?
                    '[\n' + gap + partial.join(',\n' + gap) + '\n' + mind + ']' :
                    '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    if (typeof rep[i] === 'string') {
                        k = rep[i];
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.prototype.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0 ? '{}' : gap ?
                '{\n' + gap + partial.join(',\n' + gap) + '\n' + mind + '}' :
                '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                    typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {
            var j;

            function walk(holder, key) {
                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.prototype.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }

            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

            if (/^[\],:{}\s]*$/
                    .test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                        .replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']')
                        .replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

                j = eval('(' + text + ')');

                return typeof reviver === 'function' ?
                    walk({'': j}, '') : j;
            }

            throw new SyntaxError('JSON.parse');
        };
    }
}());

/* window.onresize 浜嬩欢
 * <description>
 *     鐢ㄤ簬瑙ｅ喅 lte ie8 & chrome 鍙婂叾浠栧彲鑳戒細鍑虹幇鐨� 鍘熺敓 window.resize 浜嬩欢澶氭鎵ц鐨� BUG.
 * </description>
 * <methods>
 *     add: 娣诲姞浜嬩欢鍙ユ焺
 *     remove: 鍒犻櫎浜嬩欢鍙ユ焺
 * </methods>
 */
var onWindowResize = function(){
    //浜嬩欢闃熷垪
    var queue = [],

    indexOf = Array.prototype.indexOf || function(){
        var i = 0, length = this.length;
        for( ; i < length; i++ ){
            if(this[i] === arguments[0]){
                return i;
            }
        }

        return -1;
    };

    var isResizing = {}, //鏍囪鍙鍖哄煙灏哄鐘舵€侊紝 鐢ㄤ簬娑堥櫎 lte ie8 / chrome 涓� window.onresize 浜嬩欢澶氭鎵ц鐨� bug
    lazy = true, //鎳掓墽琛屾爣璁�

    listener = function(e){ //浜嬩欢鐩戝惉鍣�
        var h = window.innerHeight || (document.documentElement && document.documentElement.clientHeight) || document.body.clientHeight,
            w = window.innerWidth || (document.documentElement && document.documentElement.clientWidth) || document.body.clientWidth;

        if( h === isResizing.h && w === isResizing.w){
            return;

        }else{
            e = e || window.event;
        
            var i = 0, len = queue.length;
            for( ; i < len; i++){
                queue[i].call(this, e);
            }

            isResizing.h = h,
            isResizing.w = w;
        }
    }

    return {
        add: function(fn){
            if(typeof fn === 'function'){
                if(lazy){ //鎳掓墽琛�
                    if(window.addEventListener){
                        window.addEventListener('resize', listener, false);
                    }else{
                        window.attachEvent('onresize', listener);
                    }

                    lazy = false;
                }

                queue.push(fn);
            }else{    }

            return this;
        },
        remove: function(fn){
            if(typeof fn === 'undefined'){
                queue = [];
            }else if(typeof fn === 'function'){
                var i = indexOf.call(queue, fn);

                if(i > -1){
                    queue.splice(i, 1);
                }
            }

            return this;
        }
    };
}.call(this);