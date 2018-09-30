# coding:utf-8
from bs4 import BeautifulSoup

html = '<title>可里老师讲道理</title>'
soup = BeautifulSoup(html)

print soup.title
print type(soup.title)


###  lxml 解析器