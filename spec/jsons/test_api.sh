#email 注册
curl -v -H 'Content-Type: application/json' -H 'Accept: application/json'  -X POST http://www.dapeimishu.com:9090/accounts/info.json -d"@user_email.json"

#发送验证码

#curl -v -X POST http://www.dapeimishu.com:9090/users/send_code.json -d"mobile=13818904081"

#手机注册
curl -v -H 'Content-Type: application/json' -H 'Accept: application/json'  -X POST http://www.dapeimishu.com:9090/accounts/info.json -d"@user_mobile.json"

#普通用户修改资料
curl -v -H 'Content-Type: application/json' -H 'Accept: application/json'  -X PUT http://www.dapeimishu.com:9090/accounts/info.json -d"@user_update.json"


#商家提交资料
curl -v -H 'Content-Type: application/json' -H 'Accept: application/json'  -X PUT http://www.dapeimishu.com:9090/accounts/info.json -d"@user_shop.json" 
