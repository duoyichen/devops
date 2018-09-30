# _*_ coding:utf-8 _*_

import urllib,re
import sys
from cgitb import html
reload(sys)
sys.setdefaultencoding('utf-8')

def get_content(page):
    url = 'http://search.51job.com/jobsearch/search_result.php?fromJs=1&jobarea=000000%2C00&district=000000&funtype=0000&industrytype=00&issuedate=9&providesalary=99&keyword=python&keywordtype=2&curr_page=2&lang=c&stype=1&postchannel=0000&workyear=99&cotype=99&degreefrom=99&jobterm=99&companysize=99&lonlat=0%2C0&radius=-1&ord_field=0&list_type=0&fromType=14&dibiaoid=0&confirmdate=9'.format(page)
    a = urllib.urlopen(url)
    html = a.read()
    html = html.decode('gbk')
    #print html.decode('gbk')  #从gbk转为unicode
    return html

#get_content(2)

def get(html):
    reg = re.compile(r'class="t1 ">.*?<a target="_blank" title="(.*?)".*?<span class="t2"><a target="_blank" title="(.*?)".*?<span class="t3">(.*?)</span>.*?<span class="t4">(.*?)</span>.*?<span class="t5">(.*?)</span>',re.S)
    items = re.findall(reg,html)
    #print 't1'
    #print items  # list
    return items

for j in range(1,10):
    html = get_content(j) #调用获取网页源码
    print '---------------------------------------------------------------------------------------------------------------------------------------------------'
    #print 't2'
    for i in get(html):
        #print 't3'
        print i[0]+'\t\t'+i[1]+'\t\t'+i[2]+'\t\t'+i[3]+'\t\t'+i[4]+'\n'
        print '-------------------------------------------------'
        with open('python.txt','a') as f:
            f.write(i[0]+'\t\t'+i[1]+'\t\t'+i[2]+'\t\t'+i[3]+'\t\t'+i[4]+'\n')