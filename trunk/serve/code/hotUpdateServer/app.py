# !/usr/bin/python
# coding:utf-8
import web,os,json,re,hashlib,zlib

urls = (
    '/hotupdate(.*)', 'Update',
    '/download(.*)', 'Download',
)

root = os.path.join(os.getcwd(),"root")
gameroot = os.path.join(root,"game")

def getVersion():
    strings = json.dumps(getServerData())
    md5obj = hashlib.md5()
    md5obj.update(strings)
    return md5obj.hexdigest()

def getServerData():
    with open(os.path.join(gameroot,"res/fileinfo.txt"),"r+") as file_obj:
        return json.loads(file_obj.read())


class Download(object):  
    def GET(self,name):
        file_path = os.path.join(gameroot,"res/"+name[1:])
        f = None  
        try:  
            f = open(file_path, "rb")  
            web.header('Content-Type','application/octet-stream')  
            web.header('Content-Disposition', 'attachment; filename=%s' % file_path)
            yield zlib.compress(f.read())
        except Exception, e:  
            print e  
            yield 'Error'  
        finally:  
            if f:  
                f.close()
                
    def POST(self,*args, **kw):
        return "hello world"

class Update(object):
    def __init__(self):
        self.reset()
    def reset(self):
        self.version = getVersion()
        self.serverdata = getServerData()

    def POST(self,*args, **kw):            
        if self.version != getVersion():
            self.reset()

    	clientdata = json.loads(zlib.decompress(web.data()))
    	updates = {}
    	for key in self.serverdata:
    		if clientdata.has_key(key):
    			if clientdata[key][0] != self.serverdata[key][0]:
    				updates[key] = self.serverdata[key]	
    		else:
    			updates[key] = self.serverdata[key]
    	result = {"code":0}
    	if len(updates) > 0:
            updates["fileinfo.txt"] = self.version
            result["code"] = 1
            result["files"] = json.dumps(updates)
    	return zlib.compress(json.dumps(result))

if __name__ == "__main__":
	app = web.application(urls, globals())
	app.run()
  