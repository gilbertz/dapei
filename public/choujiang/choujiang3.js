
var shareUrl = "";
var shareTitle = "";
var shareDesc = "";
var shareinfoId = "";
var network="";
window.onload = function () {
     //测试
     //document.getElementById("user_id").value="1";
     //测试中奖
      //cwxbox.box.show(document.getElementById("su_cwxCn").innerHTML,true);return;
//    if (IsPC()) { window.location.href = "http://www.wangtu.com/weixin/page/ChouJiang_pc.aspx?dlid=4106"; }
    var openid = document.getElementById("user_id").value;
    if (openid == null || openid == "") { cwxbox.box.show("连接失败，请重新打开页面，如不能解决问题请更换手机再试！"); }
         scroll();
        document.getElementById("over").style.display = "none";
        createXmlHttpRequest();

    //隐藏右上角按钮
    document.addEventListener('WeixinJSBridgeReady', function onBridgeReady() {
        WeixinJSBridge.call('showOptionMenu');
        WeixinJSBridge.call('hideToolbar');
    });
    document.addEventListener("WeixinJSBridgeReady", onWeixinReady, false);
        
    //隐藏导航
    function onBridgeReady() {
        document.addEventListener('WeixinJSBridgeReady', function onBridgeReady() {
            WeixinJSBridge.call('hideToolbar');
        });
    }

    if (typeof WeixinJSBridge == "undefined") {
        if (document.addEventListener) {
            document.addEventListener('WeixinJSBridgeReady', onBridgeReady, false);
        } else if (document.attachEvent) {
            document.attachEvent('WeixinJSBridgeReady', onBridgeReady);
            document.attachEvent('onWeixinJSBridgeReady', onBridgeReady);
        }
    } else {
        onBridgeReady();
    }
    function onWeixinReady() {
         WeixinJSBridge.invoke('getNetworkType', {}, function (e) {

             WeixinJSBridge.log(e.err_msg);

             network = e.err_msg.split(":")[1];  //结果在这里

     });
    }
    //document.getElementById("top_img").style.width = window.innerWidth + "px";
    //setInterval('marqueeTip()',28000);
    shareinfoId=document.getElementById("HIDshareinfoId").value;

    shareUrl = "http://www.shangjieba.com/events/choujiang";
    shareTitle = document.getElementById("HIDtitle").value;
    shareDesc = document.getElementById("HIDdesc").value;

}

/*
* 微信转发方案
*/
var dataForWeixin = {
    appId: "",
    MsgImg: "http://1251008728.cdn.myqcloud.com/1251008728/2014/08/28/cj_logo2.jpg",
    TLImg: "http://1251008728.cdn.myqcloud.com/1251008728/2014/08/28/cj_logo2.jpg",
    title: "iPhone6免费拿，100%中奖",
    desc: "iPhone6免费拿，100%中奖",
    fakeid: "",
    callback: function () {
        $("#user_score span").text(parseInt($("#user_score span").text()) + 1);
    }
};
(function () {
    var onBridgeReady = function () {
        WeixinJSBridge.on('menu:share:appmessage', function (argv) {
            WeixinJSBridge.invoke('sendAppMessage', {
                "appid": dataForWeixin.appId,
                "img_url": dataForWeixin.MsgImg,
                "img_width": "120",
                "img_height": "120",
                "link": shareUrl,
                "desc": shareDesc,//dataForWeixin.desc,
                "title": shareTitle,//dataForWeixin.title
            }, function (res) { (dataForWeixin.callback)(); });
        });
        WeixinJSBridge.on('menu:share:timeline', function (argv) {
            (dataForWeixin.callback)();
            WeixinJSBridge.invoke('shareTimeline', {
                "img_url": dataForWeixin.TLImg,
                "img_width": "120",
                "img_height": "120",
                "link": shareUrl,
                "desc": shareDesc,
                "title": shareTitle
            }, function (res) { });
        });
        WeixinJSBridge.on('menu:share:weibo', function (argv) {
            WeixinJSBridge.invoke('shareWeibo', {
                "content": dataForWeixin.title,
                "url": shareUrl
            }, function (res) { (dataForWeixin.callback)(); });
        });
        WeixinJSBridge.on('menu:share:facebook', function (argv) {
            (dataForWeixin.callback)();
            WeixinJSBridge.invoke('shareFB', {
                "img_url": dataForWeixin.TLImg,
                "img_width": "120",
                "img_height": "120",
                "link": shareUrl,
                "desc": shareDesc,
                "title": shareTitle
            }, function (res) { });
        });
    };
    if (document.addEventListener) {
        document.addEventListener('WeixinJSBridgeReady', onBridgeReady, false);
    } else if (document.attachEvent) {
        document.attachEvent('WeixinJSBridgeReady', onBridgeReady);
        document.attachEvent('onWeixinJSBridgeReady', onBridgeReady);
    }
})();


/*
* 删除左右两端的空格
*/
function Trim(str) {
    return str.replace(/(^\s*)|(\s*$)/g, "");
}

/*
* 转盘代码初始化
*/
function GetSide(m, n) {
    //初始化数组
    var arr = [];
    for (var i = 0; i < m; i++) {
        arr.push([]);
        for (var j = 0; j < n; j++) {
            arr[i][j] = i * n + j;
        }
    }
    //获取数组最外圈
    var resultArr = [];
    var tempX = 0,
             tempY = 0,
             direction = "Along",
             count = 0;
    while (tempX >= 0 && tempX < n && tempY >= 0 && tempY < m && count < m * n) {
        count++;
        resultArr.push([tempY, tempX]);
        if (direction == "Along") {
            if (tempX == n - 1)
                tempY++;
            else
                tempX++;
            if (tempX == n - 1 && tempY == m - 1)
                direction = "Inverse"
        }
        else {
            if (tempX == 0)
                tempY--;
            else
                tempX--;
            if (tempX == 0 && tempY == 0)
                break;
        }
    }
    return resultArr;
}

var index = 0,           //当前亮区位置
       prevIndex = 0,          //前一位置
       Speed = 300,           //初始速度
       Time,            //定义对象
       arr = GetSide(3, 4),         //初始化数组
         EndIndex = 0,           //决定在哪一格变慢
         tb = document.getElementById("tb"),     //获取tb对象 
         cycle = 0,           //转动圈数   
         EndCycle = 0,           //计算圈数
        flag = false,           //结束转动标志 
        quick = 0;           //加速
//btn = document.getElementById("btn1")
//转盘代码初始化结束


/*
* 抽奖启动
* @num为转盘停止的格数
* @islottery，该次是否中奖
*/
function StartGame(num, result, islottery) {
    clearInterval(Time);
    cycle = 0;
    flag = false;
    //EndIndex = Math.floor(Math.random() * 10);
    //EndIndex = EndIndex > 10 || EndIndex == 0 ? 10 : EndIndex;
    EndIndex = 7;
    EndCycle = Math.floor(Math.random() * (10 - 5) + 5);
    //EndCycle = 5;
    Time = setInterval("Star(" + num + ",'" + result + "'," + islottery + ")", Speed);
}
function Star(num, result, islottery) {
    //跑马灯变速
    if (flag == false) {
        //走五格开始加速
        if (quick == 3) {
            clearInterval(Time);
            Speed = 50;
            Time = setInterval("Star(" + num + ",'" + result + "'," + islottery + ")", Speed);
        }
        if (num == 10) {
            //跑N圈减速
            if (cycle == (EndCycle + 1) && index == parseInt(1)) {
                clearInterval(Time);
                Speed = 300;
                flag = true;       //触发结束
                Time = setInterval("Star(" + num + ",'" + result + "'," + islottery + ")", Speed);

            }
        } else {
            //跑N圈减速
            if (cycle == (EndCycle + 1) && index == parseInt(EndIndex)) {
                clearInterval(Time);
                Speed = 300;
                flag = true;       //触发结束
                Time = setInterval("Star(" + num + ",'" + result + "'," + islottery + ")", Speed);

            }
        }
    }

    if (index >= arr.length) {
        index = 0;
        cycle++;
    }

    //结束转动并选中号码
    //trim里改成数字就可以减速，变成Endindex的话就没有减速效果了
    if (flag == true && index == parseInt(Trim('' + num)) - 1) {
        quick = 0;
        clearInterval(Time);
    }
    tb.rows[arr[index][0]].cells[arr[index][1]].className = "playcurr";
    if (index > 0)
        prevIndex = index - 1;
    else {
        prevIndex = arr.length - 1;
    }
    tb.rows[arr[prevIndex][0]].cells[arr[prevIndex][1]].className = "playnormal";
    index++;
    quick++;
    if (flag == true && index == parseInt(Trim('' + num))) {
        //设置中奖弹窗背景图片
        var result1=result.split(",");
//        document.getElementById("su_cwxCn_img").src = "/weixin/image/jp/"+result1[0]+"/2.png";

        document.getElementById("su_cwxCn_img").src = "http://1251008728.cdn.myqcloud.com/1251008728/2014/08/28/"+result1[0]+".jpg"

        //设置中奖结果
        document.getElementById("su_cwxCn_text").innerHTML=result1[2];
        cwxbox.box.show(document.getElementById("su_cwxCn").innerHTML,true);
        document.getElementById("liji1").innerHTML = "再抽一次";
        document.getElementById("over").style.display = "none";
        choujianging = false;
    }

}
//AJAX
var xmlHttp;      //这个函数是一直固定不变的，你只需要调用它，检验是否能创建 XMLHttpRequest对象
function createXmlHttpRequest() {
    if (window.XMLHttpRequest) {
        xmlHttp = new XMLHttpRequest();

        if (xmlHttp.overrideMimeType) {
            xmlHttp.overrideMimeType("text/xml");
        }
    }
    else if (window.ActiveXObject) {
        try {
            xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (e) {
            xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
    }
    if (!xmlHttp) {
        //window.alert
        cwxbox.box.show("你的浏览器不支持创建XMLhttpRequest对象 \n- 请换用IE 或 火狐");
    }
    return xmlHttp;
}
//是否正在抽奖
var choujianging = false;
//抽奖ajax调用
function ChouJiang() {
    window.scrollTo(0, document.getElementById("kuang1").offsetTop);
    var openid = document.getElementById("user_id").value;
    if (openid == null || openid == "") {
        cwxbox.box.show("连接失败，请重新打开页面，如不能解决问题请更换手机再试！");
    } else {
        if (!choujianging) {
            var share_count = parseInt($("#user_score span").text());
            //document.getElementById("cwxCn").innerHTML = r[2];
            if(share_count>=5){
                var left_count = share_count - 5;
                document.getElementById("user_score").innerHTML = "转发数：<span>"+left_count+"</span>个";
                choujianging = true;
                document.getElementById("over").style.display = "block";
                xmlHttp.open("GET", "/events/choujiang_lucky?op=ChouJiang3&openid=" + openid + "&cache=" + Math.random(), true);
                xmlHttp.onreadystatechange = GetResult;
                xmlHttp.send(null);
            }else{
                document.getElementById("user_score").innerHTML = "转发数：<span>"+share_count+"</span>个";
                document.getElementById("show_score").innerHTML = "离抽奖还差"+(5-share_count)+"个转发！";
                cwxbox.box.show(document.getElementById("text_cwxCn1").innerHTML,"1");
                document.getElementById("over").style.display = "none";
                choujianging = false;
            }
        }
    }
}

//抽奖ajax结果处理
function GetResult() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
        var result1 = xmlHttp.responseText;
        //alert(result1);
        var r = result1.split(";");
        if (r[0] == "true") {
            var result = new Array();
            result[0] = r[1];
            result[1] = r[2];
            result[2] = r[3];

            StartGame(parseInt(r[2]), "" + result);
//            switch (r[2]) {
//                case "8": StartGame(3, "" + result); break;
//                case "9": StartGame(5, "" + result); break;
//                case "6": StartGame(2, "" + result); break;
//                case "10": StartGame(7, "" + result); break;
//                case "7": StartGame(8, "" + result); break;
//                default: StartGame(10, "" + result);
//            }

            //StartGame(10, "" + r[1], true);
//            document.getElementById("user_score").innerHTML = "转发数：0个";

        } else {


        }

    }
}

//获取滚动栏所需中奖用户信息列表
//function GetUserInfoList() {
//    if (createXmlHttpRequest()) {
//        xmlHttp.open("GET", "/weixin/ajax/Program.aspx?op=GetUserInfoList2&cache=" + Math.random(), true);
//        xmlHttp.onreadystatechange = GetUserInfoListResult;
//        xmlHttp.send(null);
//    }
//}
//function GetUserInfoListResult() {
//    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
//        var result1 = xmlHttp.responseXML;
//        //alert(xmlHttp.responseText);
//        if(result1!=null){
//            var reg = /(\d{3})\d{4}(\d{4})/;
//            var xmlDoc = result1;
//            document.getElementById("lie1").innerHTML = "";
//            var nodeList = xmlDoc.documentElement.getElementsByTagName("ds");  // IE
//            for (var i = 0; i < nodeList.length; i++) {
//                document.getElementById("lie1").innerHTML += "<li><b class=\"xinxi1\">" + (nodeList[i].getElementsByTagName("phone"))[0].firstChild.nodeValue.replace(reg, "$1****$2") + "</b><b class=\"xinxi2\">" + namereplace((nodeList[i].getElementsByTagName("username"))[0].firstChild.nodeValue) + "</b><b class=\"xinxi3\">奖品已领取</b></li>";
//            }
//            scroll();
//        }
//        //InsertBrowse();
//        document.getElementById("over").style.display = "none";
//    }
//}
//滚动函数
function scroll() {
    var speed = 250;
    var liebiao = document.getElementById("liebiao");
    var liebiao2 = document.getElementById("lie2");
    var liebiao1 = document.getElementById("lie1");
    liebiao2.innerHTML = liebiao1.innerHTML
    function Marquee() {
        if (liebiao2.offsetTop - liebiao.scrollTop <= 0)
            liebiao.scrollTop -= liebiao1.offsetHeight
        else {
            liebiao.scrollTop++
        }
    }
    var MyMar = setInterval(Marquee, speed)
    liebiao.onmouseover = function () { clearInterval(MyMar) }
    liebiao.onmouseout = function () { MyMar = setInterval(Marquee, speed) }
}

function IsPC() {
    var userAgentInfo = navigator.userAgent;
    var Agents = new Array("Android", "iPhone", "SymbianOS", "Windows Phone", "iPad", "iPod");
    var flags = true;
    for (var v = 0; v < Agents.length; v++) {
        if (userAgentInfo.indexOf(Agents[v]) > 0) { flags = false; break; }
    }
    return flags;
}
//替换信息栏姓名函数
function namereplace(name) {
    var n = name.split("");
    for (i = 1; i < n.length; i++) {
        n[i] = n[i].replace(n[i], "*");
    }
    return n.join("");
}

function AddWX()
{
    cwxbox.box.show(document.getElementById("AddWXInfo").innerHTML,true);return;
}
