<br>
## python 自动登陆 cacti 获取主机流量图
<br>

https://github.com/duoyichen/devops/blob/master/cacti_screenshot.py.txt<br>

```python
#/usr/bin/env python
# -*- coding: utf-8 -*-
import os,time,datetime,socket,urllib,urllib2,cookielib


threeDayAgo = (datetime.datetime.now() - datetime.timedelta(days = 10))
otherStyleTime = threeDayAgo.strftime("%Y-%m-%d %H:%M:%S")
#print otherStyleTime
format_otherStyleTime = "%s 00:00:00" % otherStyleTime.split()[0]
#print format_otherStyleTime
start=time.mktime(time.strptime(format_otherStyleTime,'%Y-%m-%d %H:%M:%S'))
start = int(start)
print(start)

threeDayAgo = (datetime.datetime.now() - datetime.timedelta(days = 4))
otherStyleTime = threeDayAgo.strftime("%Y-%m-%d %H:%M:%S")
#print otherStyleTime
result = "%s 00:00:00" % otherStyleTime.split()[0]
#print result
end=time.mktime(time.strptime(result,'%Y-%m-%d %H:%M:%S'))
end = int(end)
print(end)

socket.setdefaulttimeout(10)
headers={}
cookiejar = cookielib.CookieJar()
urlOpener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookiejar))

# login
values = {'action':'login', 'login_username':'admin','login_password':'password' }
data = urllib.urlencode(values)
request = urllib2.Request("http://106.3.37.133/index.php", data ,headers)
res = urlOpener.open(request).read()

# get image
now = datetime.datetime.now()
date1 = now.strftime("%Y-%m-%d")
date2 = now.strftime("%Y-%m")<br>
#cacti = {'599':"Chaoxing_HI", '338':"Chaoxing_G04", '341':"Chaoxing_F789", '600':"Chaoxing_OS", '352':"DFRT_Uplink"}
cacti = {'599':"Chaoxing_HI", '600':"Chaoxing_OS", '352':"DFRT_Uplink"}

for k,v in cacti.items():
    print(k)
    request = urllib2.Request("http://106.3.37.133/graph_image.php?local_graph_id=%s&rra_id=0&view_type=tree&graph_start=%s&graph_end=%s" %(k,start,end),None,headers)
    res = urlOpener.open(request).read()
    path = '/var/www/html/o/cacti' + '/' + '%s'%date2 + '/' + '%s'%v
    print(path)
    isExists = os.path.exists(path)
    if not isExists:
        os.makedirs(path)
    #filename = "%s"%v + "%s"%(date1) + '.png'
    filename = "%s"%(date1) + '.png'
    file_object = open("%s/%s"%(path,filename), 'wb')
    file_object.write(res)
    file_object.close()
```
