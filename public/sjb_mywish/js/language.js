/**
 * This is a multiple language framework. It will support mutiple lanugage both in HTML and js context.
 *
 */
 
var sapLang = {};
sapLang.languageList = {
  "ZH_CN": "zh-CN",
  "EN": "en"
};
sapLang.defaultLang = sapLang.languageList.ZH_CN;
sapLang.currentLang = function() {
  var currentLang = GLOBAL.URL.getURLParameter('lang') || sapLang.defaultLang;
  return currentLang;
}();
sapLang.langText = {
      "zh-CN": {
    "welcome": "点击时尚物品图片，即可收藏。",
    "loginNote": "使用E-mail账号登录",
    "username": "邮箱",
    "password": "密码",
    "signin": "登录",
    "submit": "加入我的愿望清单",
    "reset": "重置",
    "cancel": "取消",
    "selected": "已选择",
    "brand": "品牌",
    "productName": "品名",
    "price": "价格",
    "category": "分类",
    "style": "风格",
    "styleSelect": "添加风格",
    "id": "货号",
    "captured": "- 已收藏",
    "note": "我的备注",
    "loginStep1": "登录过MyRunway App吗？请用同一账号登录。",
    "loginStep2": "若没有，可以通过新浪微博或QQ账号快捷登录。",
    
    "productNameTip": "添加商品名",
    "idTip": "[货号]",
    "chooseImg": "选择图片上传",
    "categoryTip": "请选择分类",
    "selectCategoryTip": "请先选择具体分类！",
    "selectImageTip": "您尚未选择图片，请先选择！",
    "maxStyleNumTip": "最多可添加6种风格！",
    "mycomment": "我的备注",
    "shareTo": "分享至",
    "resultMessage": "添加成功！",
    "resultWords": "您可以在MyRunway App的愿望清单中查看添加的宝贝哦！",
    "toDownload": "还没下载？马上下载MyRunway",
    "iPhoneDownload": "iPhone 版下载",
    "androidDownload": "Android 版下载",
    "Bad username or password!": "用户名或密码错误",
    "ACCOUNT_NOT_FOUND": "此帐号不存在",
    "100001": "匿名用户没有权限提交",
    "100002": "无法收藏此图片",
    "100003": "重复的图片，你已经收藏过这件商品了哦！",
    "110001": "用户名不能为空",
    "110002": "密码不能为空",
    "styleMaxLengthTip": "最多可输入20个字母或汉字",
    "loadingTip": "提交中"
  },
  "en": {
    "welcome": "Select the pictures of the product you like.",
    "loginNote": "Please sign in by E-mail",
    "username": "E-mail",
    "password": "Password",
    "signin": "Sign in",
    "submit": "Add to my wish list",
    "reset": "Reset",
    "cancel": "Cancel",
    "selected": "Selected",
    "brand": "Brand",
    "productName": "Product Name",
    "price": "Price",
    "category": "Category",
    "style": "Style",
    "styleSelect": "Add styles",
    "id": "ID",
    "captured": "- Collected",
    "note": "Note",
    "loginStep1": "Have Myrunway App account? Please use it to sign in.",
    "loginStep2": "If not, quick access with Facebook or Twitter.",
    
    "productNameTip": "Add product name",
    "idTip": "[ID]",
    "chooseImg": "Choose images to upload",
    "categoryTip": "Please select a category",
    "selectCategoryTip": "Please select a sub-category first!",
    "selectImageTip": "No images selected, please select some images first!",
    "maxStyleNumTip": "UP to 6 styles!",
    "mycomment": "My comments",
    "shareTo": "Share to",
    "resultMessage": "Successful!",
    "resultWords": "You may view the product in your wish list of MyRunway App now!",
    "toDownload": "Not download MyRunway App yet?",
    "iPhoneDownload": "iPhone Download",
    "androidDownload": "Android Download",
    "Bad username or password!": "Incorrect user name or password",
    "ACCOUNT_NOT_FOUND": "Account not exist",
    "100001": "Anonymous user not allowed",
    "100002": "Image can’t be fetched",
    "100003": "Repeat images! You have already captured this item.",
    "110001": "Please enter username",
    "110002": "Please enter password",
    "styleMaxLengthTip": "20 characters limited",
    "loadingTip": "Submitting"
  }
};

sapLang.getCurrentLangText = function() {
  var currentLang = sapLang.getCurrentLanguage();
  return sapLang.langText[currentLang]|| sapLang.langText[sapLang.defaultLang];
};

sapLang.getLangTextByLanguage = function(langName) {
  return sapLang.langText[langName]|| sapLang.langText[sapLang.defaultLang];
};
 
sapLang.getText = function(index) {
  var currentLang = sapLang.getCurrentLanguage();
  return sapLang.langText[currentLang][index] || sapLang.langText[sapLang.defaultLang][index] || index;
};
/**
* Get the language version of the browser, not the user defined lauguage.
*/
sapLang.getCurrentLanguage = function() {
  var currentLang = GLOBAL.URL.getURLParameter('lang') || sapLang.defaultLang;
  return currentLang;
};

/**
 * Translate the text in the HTML.
 * @param {dom} domObj An dom object under which text will be translated.
 * @param {string} sTag The HTML tag name in which text will be translated.
 */
sapLang.translatePage = function(domObj, sTag) {
  var e = domObj.getElementsByTagName(sTag);

  var currentLangText = sapLang.getCurrentLangText();
  var E,s;
  for (var i = 0; i < e.length; i++) {
    if (E = e[i].getAttribute('iLikeLang')) {
      if (currentLangText[E]) {
        e[i].innerHTML = currentLangText[E];
      }
    }
  }
  
  var inputDoms = domObj.getElementsByTagName("input");
  for (var i = 0; i < inputDoms.length; i++) {
    if (E = inputDoms[i].getAttribute('iLikeLang')) {
      if (currentLangText[E]) {
        inputDoms[i].value = currentLangText[E];
      }
    }
  }
}

sapLang.init = function() {
//  var domObj = document.getElementById("info-list");
  sapLang.translatePage(document, 'p');
  sapLang.translatePage(document, 'label');
  sapLang.translatePage(document, 'a');
  sapLang.translatePage(document, 'span');
  sapLang.translatePage(document, 'textarea');
};

sapLang.init();

