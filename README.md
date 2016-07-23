#
# Json_lamp
![json_lamp](http://git.oschina.net/uploads/images/2016/0708/231816_ae1f13cb_497742.png "json_lamp")


#安装
```
sh start.sh
```

![json_lamp](http://git.oschina.net/uploads/images/2016/0708/231535_4c7ee53f_497742.png "json_lamp")


#多站点配置：
```
复制： /lamp/server/apache/conf.d/【唯一标识】-vhosts.conf   
配置：【唯一标识】-vhosts.conf      
生效：service httpd restart                               
```

#Json_lamp结构
```
     mysql目录： /lamp/server/mysql（默认密码：admin）
mysql data目录： /lamp/server/data
       php目录： /lamp/server/php
    apache目录： /lamp/server/apache                           
```

#命令一览：
```
 mysql命令： service mysql (start|stop|restart|reload|status)
apache命令： service httpd (start|stop|restart|reload|status)
```

#网站根目录：
```
默认web根目录： /lamp/wwwroot
```

![json_lamp安装完成](http://git.oschina.net/uploads/images/2016/0708/231635_46dd236b_497742.png "json_lamp安装完成")