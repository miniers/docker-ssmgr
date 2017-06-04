# docker-ssmgr

##### 管理端

需要预先准备好 webgui.yml 文件放置在 /data/docker/ssmgr 目录中

SSMGR_PASSWORD：受控端管理密码

-p 7000:80 webgui外部访问端口,容器内端口（webgui.yml 中配置）

-p 38000-38100:38000-38100 ss 映射端口，

` docker run -d -v /data/docker/ssmgr:/root/.ssmgr/ -p 7000:80 -p 38000-38100:38000:38100 -e SSMGR_PASSWORD=123456 miniers/docker-ssmgr `

##### 受控端

不需要准备任何文件

SSMGR_PASSWORD：管理密码

4001：管理端接入端口

38000-38100:shadowsock 映射端口，可自行更改


` docker run -d -v /data/docker/ssmgr:/root/.ssmgr -p 4001:4001 -p 38000-38100:38000-38100 -e SSMGR_PASSWORD=123456 miniers/docker-ssmgr `


##### webgui.yml 模板

``` 
type: m
empty: false

manager:
  address: 127.0.0.1:4001
  password: '123456'
  # 这部分的端口和密码需要跟上一步 manager 参数里的保持一致，以连接 type s 部分监听的 tcp 端口
plugins:
  flowSaver:
    use: true
  user:
    use: true
  account:
    use: true
    pay:
      hour:
        price: 0.03
        flow: 500000000
      day:
        price: 0.5
        flow: 7000000000
      week:
        price: 3
        flow: 50000000000
      month:
        price: 10
        flow: 200000000000
      season:
        price: 30
        flow: 200000000000
      year:
        price: 120
        flow: 200000000000
  email:
    use: true
    username: 'username'
    password: 'password'
    host: 'smtp.your-email.com'
    # 这部分的邮箱和密码是用于发送注册验证邮件，重置密码邮件
  webgui:
    use: true
    host: '0.0.0.0'
    port: '80'
    site: 'http://yourwebsite.com'
    gcmSenderId: '456102641793'
    gcmAPIKey: 'AAAAGzzdqrE:XXXXXXXXXXXXXX'
  alipay:
    use: true
    appid: 2015012108272442
    notifyUrl: 'http://yourwebsite.com/api/user/alipay/callback'
    merchantPrivateKey: 'xxxxxxxxxxxx'
    alipayPublicKey: 'xxxxxxxxxxx'
    gatewayUrl: 'https://openapi.alipay.com/gateway.do'

db: 'webgui.sqlite'
```
