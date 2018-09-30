# _*_ coding:utf-8 _*_
import urllib2,urllib
from bs4 import BeautifulSoup

x=0
url = 'http://www.dbmeinv.com/?pager_offset=%1'
def crawl(url):
    headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Maxthon/4.9.3.1000 Chrome/39.0.2146.0 Safari/537.36'}
    req = urllib2.Request(url,headers=headers)
    page = urllib2.urlopen(req,timeout=20)
    contents = page.read()#获取源码
    #print contents

    soup = BeautifulSoup(contents,'html.parser')#对象
    my_girl = soup.find_all('img')#从源码中间去找到img图片标签
    for girl in my_girl:
        link = girl.get('src')
        print link

        global x
        urllib.urlretrieve(link,'images\%s.jpg' % x)
        x += 1
        print ("正在下载第%s张" % x)

for page in range(1,3):
    page += 1
    url = 'http://www.dbmeinv.com/?pager_offset=%s' % page
    crawl(url)

print "报告长官，图片下载完毕"