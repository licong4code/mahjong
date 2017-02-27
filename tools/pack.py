# !/bin/usr/python
# coding:utf-8

import os,sys,hashlib,json,shutil,platform,xlrd,re,time,sqlite3,subprocess
# from excel2lua import Excel2Lua 

# 引擎路径
QUICK_V3_ROOT = os.getenv("QUICK_V3_ROOT")

reload(sys)
sys.setdefaultencoding('utf-8')

CURDIR = os.path.split(os.path.realpath(__file__))[0]

def saveToFile(strings,filepath):
	file_obj = open(filepath,"w")	     
	file_obj.write(strings)
	file_obj.close()

def MD5(filepath):
    with open(filepath,'rb') as f:
        md5obj = hashlib.md5()
        md5obj.update(f.read())
        return md5obj.hexdigest()

def getFilesMD5(dirname):
	info = {}
	size = {}
	for root, dirs, files in os.walk(dirname): 
	    for f in files: 
	    	filepath = os.path.join(root, f)
	    	abspath = filepath.replace(dirname,"")
	    	abspath = abspath.replace("\\","/")[1:]
	    	if f != ".DS_Store":  
		        info[abspath] = (MD5(filepath),os.path.getsize(filepath))
		
	return info,size

# 压缩文件
def compressFiles():
	os.system('python %s'%os.path.join(PATH_SCRIPT,"compressPNG/tools.py"))
	pass

def isChange(root,md5file):
	_change = False
	filesmd5,__ = getFilesMD5(root)
	if os.path.exists(md5file):
		file_obj = open(md5file,"r") 
		pre_filesinfo = json.loads(file_obj.read())
		if len(pre_filesinfo) == len(filesmd5):
			for key in filesmd5:
				if not pre_filesinfo.has_key(key):
					_change = True
					break
					
				if filesmd5[key] != pre_filesinfo[key]:
					_change = True
					break
		else:
			_change = True
	else:
		_change = True

	return _change,filesmd5

class DealResource:
	def __init__(self,project_path):
		self._path = project_path
	def getRevision(self):
		revision = "error"
		client_path = os.path.join(CURDIR,"../trunk/client")
		
		if platform.system()  == "Windows":
			dbpath = os.path.join(CURDIR,"../")
			try:
				# print os.path.realpath(dbpath)
				sql = '''select revision from NODES_BASE where repos_path == "mahjong/trunk/client"'''
				db = sqlite3.connect(dbpath+"/.svn/wc.db")
				cursor = db.cursor()
				cursor.execute(sql)
				revision = str(cursor.fetchall()[0][0])
			except Exception,e:
				print e
		else:
			revision = subprocess.check_output("svn info %s | awk '/^Last Changed Rev:/ {print $4}'"%(client_path), shell=True).strip()
		return revision+"."+self.getBuildVersion()

	def getVersionCode(self):
		ver = ""
		with open(os.path.join(self._path,"client/verNo")) as file_obj:
			ver = file_obj.read()
		return ver+"."+self.getRevision()

	def getBuildVersion(self):
		ver = ""
		bv_path = os.path.join(CURDIR,"buildversion.txt")
		try:
			with open(bv_path) as file_obj:
				ver = file_obj.read()
		except Exception,e:
			ver = "0"
			
		if ver == "":
			ver = "0"
		with open(bv_path,"w+") as file_obj:
			file_obj.write(str(int(ver)+1))

		return ver
	def run(self):
		inpath = os.path.join(self._path,"res")
		outfile = os.path.join(self._path,"res/fileinfo.txt")
		
		if not os.path.exists(inpath):
			os.makedirs(inpath)

		if os.path.exists(outfile):
			os.remove(outfile)
		info,size = getFilesMD5(inpath)
		# config = {}
		# config["version"] = self.getRevision()
		# config["files"] = info
		strings = json.dumps(info)

		with open(outfile,"w") as file_obj:
			file_obj.write(strings)

class Packer:
	# sys.argv[1]
	def __init__(self,root,_channelID,_platform,_projectPath):
		self.root = root                                  				# 整个工程目录（client上级）
		self.projectPath = _projectPath									# 单个工程目录（android/ios）
		self.channelID = _channelID            							# 渠道ID
		self.platform = _platform                                       # 平台
		self.configPath = os.path.join(root,"platform_config")			# 计费配置
		self.outResPath = os.path.join(root,"res")        				# 加密后的资源路径
		self.codeZipPath = os.path.join(root,"res")    					# 打包后脚本路径
		self.curPath = os.path.dirname(sys.argv[0])     			    # 当前路径
		self.suffix = "sh" if platform.system() != "Windows" else "bat"
		self.deal = DealResource(self.root)

	# 加密脚本
	def encryptCode(self,inPath,outPath):
		def excute(inPath,outPath,bit):
			sign = "lcandx10"
			key = "8c1f4c6e"
			command = ("%s -i %s -x cocos,framework -o %s -e xxtea_zip -ek %s -es %s -b %d")%(os.path.join(QUICK_V3_ROOT,"quick/bin/compile_scripts."+self.suffix),inPath,os.path.join(outPath,"game%d.zip"%bit),key,sign,bit)
			os.system(command)
			time.sleep(1)
			command = ("%s -i %s -x app,config,main -o %s -e xxtea_zip -ek %s -es %s -b %d")%(os.path.join(QUICK_V3_ROOT,"quick/bin/compile_scripts."+self.suffix),inPath,os.path.join(outPath,"framework%d.zip"%bit),key,sign,bit)
			os.system(command)
		excute(inPath,outPath,32)
		if self.platform == "ios":
			excute(inPath,outPath,64)
		

	# 加密文件
	def encryptFiles(self,srcPath,dstPath):
		if os.path.exists(dstPath):
			shutil.rmtree(dstPath)
		os.system(("%s -i %s -o %s -es LTSTUDIO -ek HuNanLT")%(os.path.join(QUICK_V3_ROOT,"quick/bin/encrypt_res."+self.suffix),srcPath,dstPath))
	
	# 压缩关卡文件
	def slimLvConfig(self):
		filterfile = os.path.join(self.curPath ,"../level_filter.lua")
		strings = ""
		with open(filterfile,"r") as f:
			strings = f.read()
		srcpath = os.path.realpath(os.path.join(self.root ,"client/src/app/data/level/")).replace("\\","/")
		if srcpath[-1:] != "/":
			srcpath = srcpath + "/"
		if platform.system() == "Windows":
			srcpath = srcpath.replace("/",r"\\\\")
			strings = re.sub(r"local platform = \S*",'local platform = "win32"',strings)
		else:
			strings = re.sub(r"local platform = \S*",'local platform = "mac"',strings)

		strings = re.sub(r"local levelpath = \S*",r'local levelpath = "%s"'%srcpath,strings)
		# print strings
		with open(filterfile,"w") as f:
			f.write(strings)
		command = ""
		if platform.system() != "Windows":
			command = "%s/quick/bin/mac/luajit64 %s"%(QUICK_V3_ROOT,filterfile)
		else:
			command = "%s/quick/bin/win32/luajit.exe %s"%(QUICK_V3_ROOT,filterfile)
		os.system(command)

	def getChannelConfig(self,channelID):
		key = str(channelID)
		table = xlrd.open_workbook(os.path.join(self.configPath,"config.xlsx")).sheets()[0]
		rows,cols = table.nrows,table.ncols
		config = {}
		for row in range(1,rows):
			item = {}
			item["channelID"] = int(table.cell(row,0).value)
			item["path"] = table.cell(row,1).value
			item["platform"] = table.cell(row,2).value
			item["desc"] = table.cell(row,3).value
			config[str(int(table.cell(row,0).value))] = item
		if config.has_key(key):
			return config[key]
		return None

	def updateVersion(self):
		print u"@@更改版本号"
		with open(os.path.join(self.root,"src/app/version.lua"),"w") as file_obj:
			file_obj.write('return "'+self.deal.getRevision()+'"')
	# 处理脚本
	def dealCode(self,channelName):

		# print u"@@导出配置文件"
		# config = self.getChannelConfig(channelName)
		# if config == None:
		# 	print "cannot find config,channel name: '%s'"%channelName
		# excelpath = os.path.join(self.configPath,config["path"])
		# print excelpath,excelpath
		# instance = Excel2Lua(excelpath,excelpath)

		# print u"@@拷贝配置文件"
		# lua_config_path = os.path.join(self.root,"client/src/app/data/config")
		# for luafile in os.listdir(excelpath):
		# 	if os.path.splitext(luafile)[1] == ".lua":
		# 		srcpath = os.path.join(excelpath,luafile)
		# 		dstpath = os.path.join(lua_config_path,os.path.split(luafile)[1])
		# 		shutil.copyfile(srcpath,dstpath)
		# 		print u"拷贝文件：%s 到：%s"%(srcpath,dstpath)

		# print u"@@修改lua文件渠道号"
		# lua_config_file = os.path.join(self.root ,"client/src/config.lua")
		# luastring = ""
		# with open(lua_config_file,"r") as file_obj:
		# 	luastring = file_obj.read()

		# luastring = re.sub(r'CHANNEL_ID = \d+', "CHANNEL_ID = %d"%config["channelID"], luastring)

		# with open(lua_config_file,"w") as file_obj:
		# 	file_obj.write(luastring)
		
		# print u"@@压缩关卡"
		# self.slimLvConfig()


		self.updateVersion()
		
		# print u"@@加密脚本"
		# md5filepath = os.path.join(self.curPath,"../code.info")
		# # 脚本路径
		code_path = os.path.join(self.root,"src")
		# need_encrypt,filesmd5 = isChange(code_path,md5filepath)
		# if need_encrypt:
		self.encryptCode(code_path,self.codeZipPath)
		

	# 加密资源
	def dealFiles(self):
		# 未加密
		respath = os.path.join(self.root,"client/res_unEncrypt/")
		# md5filepath = os.path.join(self.curPath,"../files.info")
		# need_encrypt,filesmd5 = isChange(respath,md5filepath)
		# compress_files_path = os.path.join(self.root,"client/res_compress/")

		# if need_encrypt:
			# 压缩
			# compressFiles()
			# 加密
		self.encryptFiles(respath,self.outResPath)
		# 	# 保存信息
		# 	saveToFile(json.dumps(filesmd5),md5filepath)	
		# else:
		# 	print "neednot encrypt res"

	def replaceAndroidSdkPath(self):
	 	sdk_root = os.getenv("ANDROID_SDK_ROOT")
	 	filepath = os.path.join(self.projectPath ,"local.properties")
		if platform.system() == "Windows":
			sdk_root = sdk_root.replace("\\","/")
		strings = ""
		with open(filepath,"r") as file_obj:
			strings = file_obj.read()
		
		strings = re.sub(r"sdk.dir=\S*","sdk.dir="+sdk_root,strings)
		with open(filepath,"w") as file_obj:
			file_obj.write(strings)
		
	def run(self):
		if self.platform == "android":
			self.replaceAndroidSdkPath()
		self.dealCode(self.channelID)
		# self.dealFiles()
		# 必须最后处理所以文件信息
		self.deal.run()

if __name__ == '__main__':
	android_path = os.path.join(CURDIR,"../trunk/client/mahjong/frameworks/runtime-src/proj.android")
	instance = Packer(os.path.join(CURDIR,"../trunk/client/mahjong"),None,"android",android_path)
	instance.run()


