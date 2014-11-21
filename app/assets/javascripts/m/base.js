var SJBenvironment = {
  windowW: $(window).width(),
  windowH: $(window).height(),
  OS: (function() {
    var UA = navigator.userAgent;
    if (UA.search(/ipad|ipod|iphone/i) !== -1) {
      return 'ios';
    } else if (UA.search(/android/i) !== -1) {
      return 'android';
    } else {
      return undefined;
    }
  })()
};
