(function(){
    if (!window.sns) {
        window.sns = {};
    }
    var WB_URL = "http://tjs.sjs.sinajs.cn/open/api/js/wb.js",
        WEIBO_APPKEY = "3795128837",
        QQ_URL = 'https://graph.qq.com/oauth2.0/authorize?client_id=100325121&redirect_uri=http://www.myrunway.com.cn/condor-1/qqlogin.jsp&scope=get_user_info,list_album,upload_pic,add_feeds,do_like&response_type=code',
        MYRUNWAY_SIGNIN = GLOBAL.URL.getUrlByDomain('/condor-1/rest/myrunway/signin');
        //MYRUNWAY_SIGNIN = 'http://www.myrunway.com.cn:8080/response.json';
        
    sns.login = function() {
        myrunwayLogin();
        weiboLogin();
        qqLogin();
        initEvents();
            
        $("#sns-login").removeClass("hidden");
        $("#login").find('h4').removeClass("hidden");
    };
    
    /*
     * Myrunway native account login 
     */
    function myrunwayLogin(){
        $("#signin").on("click", function(){
            $('#login').click();

            if (!$("#username").val()) {
                sap.messageBox.showMsg(sapLang.getText("110001"));
                $("#username").focus();
            } else if (!$("#password").val()) {
                sap.messageBox.showMsg(sapLang.getText("110002"));
                $("#password").focus();
            } else {
                var signInObj = {};
                signInObj.snsProvider = "DEFAULT";
                signInObj.snsAccount = $("#username").val();
                signInObj.password = $("#password").val();
                signInObj.isMyRunwayLogin = "true";
                var reqData = JSON.stringify({SignInVO: signInObj});
                signinMyRunway(reqData);
                $("#share").hide(); 
            }
            
            return false;
        });
        
        $(document).on('keypress', function(e) {
            if(e.keyCode == 13 && !$("#login").hasClass("hidden")) {
                $("#signin").click();
            }
        });
    }
    
    /*
     * Weibo account login
     */
    function weiboLogin() {
        $.getScript(WB_URL + "?appkey=" + WEIBO_APPKEY, function(){
            /*
             * Weibo login & get the user data by weibo account
             */
            $('#wb_connect_btn').on('click', function() {
                WB2.login(function() {
                    WB2.anyWhere(function(W){
                        W.parseCMD("/users/show.json", function(o, bStatus){
                            var signInObj = {};
                            signInObj.expires = new Date().getTime() + parseInt(WB2.oauthData.expires_in) * 1000;
                            signInObj.cityId = o.province + "_" + o.city;
                            signInObj.access_token = WB2.oauthData.access_token;
                            signInObj.snsAccount = WB2.oauthData.uid;
                            signInObj.headIconId = o.profile_image_url;
                            signInObj.gender = o.gender;
                            signInObj.snsProvider = "SINAWEIBO";
                            signInObj.nickname = o.name;
                            var reqData = JSON.stringify({SignInVO: signInObj});
                            GLOBAL.storage.saveItem('accessToken', WB2.oauthData.access_token, false);
                            signinMyRunway(reqData, signInObj.expires, "SINAWEIBO");
                            $("#share").addClass("weibo-on");
                        },{
                            access_token: WB2.oauthData.access_token,
                            uid: WB2.oauthData.uid
                        },{
                            method: 'GET'
                        });
                    });
                });
            });
        });
    }
    
    /*
     * QQ account login
     */
    function qqLogin() {
        $('#qqLoginBtn').on('click', function() {
            var top = (document.documentElement.clientHeight - 460) / 2,
                left = (document.documentElement.clientWidth - 460) / 2;
            window.open(QQ_URL, 'qqLogin', 'height=460,width=460,depended=yes,top='+top+',left='+left);
            
            initImageListDiv();
            $("#share").addClass("qzone-on");
        });
    }
    
    function signinMyRunway(reqData, expires, userType){
        $.ajax({
            type: 'GET',
            url: MYRUNWAY_SIGNIN,
            contentType: "application/json; charset=utf-8",
            data: reqData,
            success: function(response){
                if (response['CondorJSONMsg'] && 'ERROR' == response['CondorJSONMsg']['Status']) {
                    var errMsg = response['CondorJSONMsg']['Message'];
                    sap.messageBox.showMsg(sapLang.getText(errMsg));
		    initImageListDiv();
                } else {
                    GLOBAL.storage.saveItem('userAccountVO', JSON.stringify(response), false);
                    expires = expires || new Date().getTime() + 7776000000;
                    GLOBAL.storage.saveItem('expires_in', expires, false);
                    
                    userType = userType || "MYRUNWAY";
                    GLOBAL.storage.saveItem('userType', userType, false);
                    
                    sap.capture(sap.postProduct);
                    
                    $("#close-btn").addClass("close-btn-capture-result");
                    $("#login").addClass("hidden");
                    if ($("#capture-result").hasClass("hidden")) {
                        $("#capture-result").removeClass("hidden");
                    }
                    
                    initImageListDiv();
                }
            },
            error: function(e){
		initImageListDiv();
//              console.log(e);
            }
        });
    }
    
    /*
     * Initialize imageList div including height setting and scrollbar initialization
     */
    function initImageListDiv() {
        var contentWrapperTop = $("div.content-wrapper").offset().top,
            imageListTop = $("#image-list").offset().top,
            CONTENT_WRAPPER_HEIGHT = 600,
            LEFT_CONTENT_PADDING_BOTTOM = 30,
            imageListHeight = CONTENT_WRAPPER_HEIGHT - (imageListTop - contentWrapperTop) - LEFT_CONTENT_PADDING_BOTTOM;
        
        $("#image-list").height(imageListHeight);
        
        sap.scrollbar.init();
    }
    
    /*
     * Initialize Dom events
     */
    function initEvents() {
        $('#login').on('click', function() {
            $('#login .login-tips').hide();
            $('#close-btn').show();
        });
        
        $('.box-style').on('click', function() {
            var input = $(this).find('input').show();
            $(this).addClass('border-active');
            $(this).find('label').hide();
            input.focus();
        });
        
        $('.box-style input').on('blur', function() {
            $(this).parent().removeClass('border-active');
            if (!$(this).val()) {
                $(this).hide();
                $(this).prev().show();
            }
        });
        
        $("#username").on('keydown', function(e) {
            if(e.keyCode == 9) {
                $('.box-style')[1].click();
                $(this).parent().removeClass('border-active');
                if (!$(this).val()) {
                    $(this).hide();
                    $(this).prev().show();
                }
                
                return false;
            }
        });
        $('body').on("click", function() {
            sap.messageBox.hideMsg();
        });
    }
})();
