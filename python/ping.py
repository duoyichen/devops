#!/usr/bin/env python 
# coding:UTF-8 
import time
import pexpect
import smtplib
from email.mime.text import MIMEText

#mail_host = "mail.cloudmind.cn"
#mail_from = "alarm@cloudmind.cn"
#mail_pass = "==--00pp"
mail_host = "smtp.163.com"
mail_from = "duoyichen@163.com"
mail_pass = "password"
#mail_to = "duoyichen@qq.com"
mail_to = "support@webcc.com"
mail_cc = "chenying@cloudmind.com"


ip_list = [
'221.7.38.204',
'36.250.7.228',
'183.251.62.131',
'117.156.241.158',
]

ip_list2 = [
'140.210.6.20',
'140.210.6.61',
'175.25.48.10',
'210.14.133.198',
'210.14.150.29',
'210.14.150.3',
'210.14.150.4',
'210.14.150.5',
'210.14.150.7',
'210.14.150.8',
'210.14.150.9',
'210.14.150.10',
'210.14.150.11',
'210.14.150.12',
#'106.3.37.117',
]

ip_list2 = "\n".join(ip_list)

def Mail(error_ip):
    date = time.strftime('%Y%m%d - %H: %M: %S')
    #msg = MIMEText("%s:  Ping %s failed!\n\nCustomer's:\n175.25.48.216\n175.25.48.223\n175.25.48.251\n175.25.48.249" % (date, error_ip))
    #msg = MIMEText("%s:  Ping %s failed!\n\nIP List:\n%s" %(date, error_ip, ip_list2))
    #msg['Subject'] = "%s  Ping %s failed!" % (date,error_ip)
    msg = MIMEText("%s:  Ping %s successful!\n\nIP List:\n%s" %(date, error_ip, ip_list2))
    msg['Subject'] = "%s  Ping %s Successful!" % (date,error_ip)
    msg['From'] = mail_from
    msg['To'] = mail_to
    msg['Cc'] = mail_cc
    try:
        s = smtplib.SMTP()
        s.connect(mail_host, "25")
        #s.connect(mail.cloudmind.cn,"25")
        #s.connect("210.14.142.15")
        s.starttls()
        s.login(mail_from,mail_pass)
        s.sendmail(mail_from, mail_to.split(',') + mail_cc.split(','), msg.as_string())
        s.quit()
    except Exception, e:
        print str(e)
for ip in ip_list:
    ping = pexpect.spawn('ping -c 1 %s' % ip)
    check = ping.expect([pexpect.TIMEOUT,"1 packets transmitted, 1 received, 0% packet loss"],2)
    if check == 1:
        Mail(ip)
        print "Ping %s failed, Send email." % ip
    if check == 0:
        #Mail(ip)
        print "Ping %s successful." % ip



'''

ip_list = [
'140.210.6.61',
'175.25.48.67',
'175.25.48.100',
'175.25.48.102',
'175.25.48.104',
'175.25.48.105',
'175.25.48.109',
'210.14.131.113',
'210.14.133.221',
'175.25.48.115',
'175.25.48.96',
'210.14.148.170',
'210.14.148.171',
'210.14.148.173',
'210.14.148.172',
'175.25.48.238',
'175.25.48.253',
'175.25.48.207',
'210.14.148.174',
'175.25.48.223',
'175.25.48.73',
'175.25.48.83',
'175.25.48.72',
'210.14.133.198',
'175.25.48.103',
'175.25.48.124',
'175.25.48.38',
'175.25.48.200',
'175.25.48.11',
'175.25.48.10',
'175.25.48.92',
'175.25.48.49',
'175.25.48.108',
'175.25.48.101',
'175.25.48.113',
'175.25.48.107',
'210.14.131.67',
'210.14.131.102',
'175.25.48.31',
'210.14.131.120',
'210.14.131.121',
'210.14.131.104',
'175.25.48.112',
'210.14.150.29',
'175.25.48.28',
'175.25.48.75',
'175.25.48.205',
'175.25.48.55',
'140.210.6.56',
'140.210.6.3',
'210.14.131.66',
'175.25.48.248',
'175.25.48.247',
'140.210.6.52',
'175.25.48.201',
'175.25.48.249',
'210.14.131.86',
'140.210.6.20',
'175.25.48.229',
]

#'210.14.131.110',
#'175.25.48.57',

'''
