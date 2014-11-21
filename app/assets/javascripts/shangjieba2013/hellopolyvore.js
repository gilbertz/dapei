jQuery(document).ready(function($){

    $("body").on("click", "#publish_btn", function(){
        $.get("/collocations/hot_dapei_tags", function(data){
            $("textarea[name=description]").parent().parent().after(data);
        });
    });

    $(body).on("click", "#dapei_tags_ul li", function(){

        var str = $("textarea[name=description]").val();
        var new_str = "";

        if($(this).hasClass("active")){

            $(this).removeClass("active");
            $("textarea[name=description]").focus();

            new_str = str.replace("#"+$(this).text()+" ", "");

        }else{
            $(this).addClass("active");

            $("textarea[name=description]").focus();

            if(str == "描述一下你要发布的搭配,并使用 #标签 来添加标签"){
                str = "";
            }

            new_str = str + " " + "#" + $(this).text() + " ";
        }

        $("textarea[name=description]").val(new_str);
    });
});