$(document).ready(function(){
    $("#encode-url").click(function(){
        var url = $("#item-url").val();
        if(url.length > 0){
            $.get("/saler/matters/get_taobao_item_by_url", {url: url}, function(data){

                var title = data["item"]["title"];
                var price = data["item"]["price"];
                var imgs = data["item"]["item_imgs"]["item_img"];
                var taobao_id = data["item"]["num_iid"];

                for(i in imgs){
                    var img = $("<img/>");
                    img.attr("src", imgs[i]["url"]);
                    img.attr("data-id", imgs[i]["id"]);
                    img.attr("class", "item-image img-thumbnail");
                    $(".item-images").append(img);
                }

                $("#title").val(title);
                $("#price").val(price);
                $("#taobao_id").val(taobao_id);
            });
        }else{
            alert("请输入淘宝商品的链接");
        }
        event.preventDefault();
        return false;
    });

    $(".item-images").on("click", ".item-image", function(){
        if($(this).hasClass("selected")){
            var data_id = $(this).attr("data-id");

            if($(this).hasClass("upload-image")){
                $(".hide-input").find("input[value="+data_id+"]").remove();
            }else{
                $(".hide-input").find("input[data-id="+data_id+"]").remove();
            }

        }else{
            var img_src = $(this).attr("src");
            var data_id = $(this).attr("data-id");

            if($(this).hasClass("upload-image")){
                var hiden_input = $("#taobao-hidden-input .upload-item-image").clone();
                $(hiden_input).val(data_id);
                $(hiden_input).attr("data-id", data_id);
                $(hiden_input).appendTo($(".hide-input"));
            }else{
                var hiden_input = $("#taobao-hidden-input .taobao-item-image").clone();
                $(hiden_input).val(img_src);
                $(hiden_input).attr("data-id", data_id);

                $(hiden_input).appendTo($(".hide-input"));
            }


        }

        $(this).toggleClass("selected");
    });

    $(".lists").hover(function(){
        $(this).find(".sub-list").show();
    });

})