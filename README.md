# devops
Operations, Shell, Python, MySql, Html, JavaScript ... etc.



## python 自动登陆 cacti 获取主机流量图
<br>

\#/usr/bin/env python<br>
\# -*- coding: utf-8 -*-<br>
import os,time,datetime,socket,urllib,urllib2,cookielib<br>


threeDayAgo = (datetime.datetime.now() - datetime.timedelta(days = 10))<br>
otherStyleTime = threeDayAgo.strftime("%Y-%m-%d %H:%M:%S")<br>
#print otherStyleTime<br>
format_otherStyleTime = "%s 00:00:00" % otherStyleTime.split()[0]<br>
#print format_otherStyleTime<br>
start=time.mktime(time.strptime(format_otherStyleTime,'%Y-%m-%d %H:%M:%S'))<br>
start = int(start)<br>
print(start)<br>

threeDayAgo = (datetime.datetime.now() - datetime.timedelta(days = 4))<br>
otherStyleTime = threeDayAgo.strftime("%Y-%m-%d %H:%M:%S")<br>
#print otherStyleTime<br>
result = "%s 00:00:00" % otherStyleTime.split()[0]<br>
#print result
end=time.mktime(time.strptime(result,'%Y-%m-%d %H:%M:%S'))<br>
end = int(end)<br>
print end<br>

socket.setdefaulttimeout(10)<br>
headers={}<br>
cookiejar = cookielib.CookieJar()<br>
urlOpener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookiejar))<br>

\# login<br>
values = {'action':'login', 'login_username':'admin','login_password':'password' }<br>
data = urllib.urlencode(values)<br>
request = urllib2.Request("http://106.3.37.133/index.php", data ,headers)<br>
res = urlOpener.open(request).read()<br>

\#get image<br>
now = datetime.datetime.now()<br>
date1 = now.strftime("%Y-%m-%d")<br>
date2 = now.strftime("%Y-%m")<br>
#cacti = {'599':"Chaoxing_HI", '338':"Chaoxing_G04", '341':"Chaoxing_F789", '600':"Chaoxing_OS", '352':"DFRT_Uplink"}<br>
cacti = {'599':"Chaoxing_HI", '600':"Chaoxing_OS", '352':"DFRT_Uplink"}<br>

for k,v in cacti.items():<br>
    print(k)<br>
    request = urllib2.Request("http://106.3.37.133/graph_image.php?local_graph_id=%s&rra_id=0&view_type=tree&graph_start=%s&graph_end=%s"%(k,start,end),None,headers)<br>
    res = urlOpener.open(request).read()<br>
    path = '/var/www/html/o/cacti' + '/' + '%s'%date2 + '/' + '%s'%v <br>
    print(path)<br>
    isExists = os.path.exists(path)<br>
    if not isExists:<br>
        os.makedirs(path)<br>
    #filename = "%s"%v + "%s"%(date1) + '.png'<br>
    filename = "%s"%(date1) + '.png'<br>
    file_object = open("%s/%s"%(path,filename), 'wb')<br>
    file_object.write(res)<br>
    file_object.close()<br>
