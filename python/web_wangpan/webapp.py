# _*_ coding: utf-8 _*_
import web
import random

urls = (
    '/','Index',
    '/upload','Upload'
)

render = web.template.render('templates')
db = web.database()
class Index:
    def GET(self):
        return render.index()

class Upload:
    def GET(self):
        return 'hello'
    def POST(self):
        ###
        i = web.input(file={})
        filename = i.file.filename
        files =
        files = i.get('file')
        with open('static/files/1.png','wb') as fn:
            fn.write(files)
        return '<a href=/static/files/1.png>上传的文件</a>'

if __name__ == '__main__':
    web.application(urls,globals()).run()