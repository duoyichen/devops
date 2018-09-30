# _*_ coding:utf-8 _*_
import web
import random
#import sys
#reload(sys)
#sys.setdefaultencoding('utf8')

urls = (
    '/','Index',
)

db = web.database(dbn='mysql',host='127.0.0.1',port=3306,user='root',pw='MySql_root_pass',db='jiangpin',charset='utf8')
j_list = [u'100元学费',u'200元学费',u'300元学费',u'500元学费',u'3年制学习权限',u'自动化运维班',u'Python项目实战班',u'LINUX特训班',u'Python文化衫',u'全套视频',u'WEB前端培训班',u'黑客教程']
render = web.template.render('templates')

def random_str():
    str1 = ''
    chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789'
    length = len(chars)-1
    for i in range(16):
        str1 += chars[random.randint(0,length)]
    return str1

class Index:
    def GET(self):
        #return 'duoyi'
        #return open('index.html',).read()
        return render.index()

    def POST(self):
        #ip = web.ctx.ip.encode("utf-8")
        ip = web.ctx.ip
        #print(type(ip))
        ips = db.query("select * from jiangpin WHERE ip = '%s'" %ip)
        if ips:
            ips = ips[0]
            #return 0
            if ips.get('cs') == 0:
                return 0
            cs = ips.get('cs') - 1
            #t_str = ips.get('sn').split(',')
            t_str = ips.sn.split(',')
            #print(t_str)
            #return t_str
            while True:
                rand_int = str(random.randint(1,12))
                if rand_int in t_str:
                    continue
                break
            #j_str = ips.get('j_list')
            j_str = ips.j_list
            #print(j_str)
            #print(type(j_str))
            #print(j_list[int(rand_int)-1])
            #print(type(j_list[int(rand_int)-1]))
            j_l = '%s,%s' %(j_str,j_list[int(rand_int)-1])
            rand_sn = '%s,%s' %(ips.get('sn'),rand_int)
            #print(rand_sn)
            #print(type(rand_sn))
            ma = ips.get('str')
            #db.query("update jiangpin set sn='11,22',cs=3,j_list='dd'")
            db.query("update jiangpin set sn='%s',cs=%s,j_list='%s'" %(rand_sn,cs,j_l))
            return '%s %s %s %s' %(rand_int,ma,2-cs,j_l)

        rand_int = random.randint(1,12)
        #print rand_int
        ma = random_str()
        #print(type(rand_int))
        #db.query("select * from jiangpin")
        db.query("insert into jiangpin(id,ip,sn,str,cs,j_list) values(NULL ,'%s','%s','%s','%s','%s')" %(str(ip),rand_int,ma,2,j_list[rand_int-1]))
        return '%s %s 0 %s' %(rand_int,ma,j_list[rand_int-1])

if __name__ == '__main__':
    web.application(urls,globals()).run()

