# _*_ coding:utf-8 _*_

from bs4 import BeautifulSoup
#html = ''
html = ''
soup = BeautifulSoup(open('a.html'))
print soup.prettify()