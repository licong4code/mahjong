# coding:
import subprocess,re,platform
for port in (9997,10000,20001,1000):
	if platform.system() != "Windows":
		res = subprocess.Popen('lsof -i tcp:%d'%port,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,close_fds=True)  
		results = res.stdout.readlines()
		p = re.compile(r'\d{3,5}')
		for line in results:
			result = p.findall(line)
			if len(result):
				subprocess.Popen('kill -9 %s'%str(result[0]),shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,close_fds=True)
	else:
		res = subprocess.Popen('netstat -ano | findstr %d'%port,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)  
		results = res.stdout.readlines()
		p = re.compile(r'\d{3,5}')
		for line in results:
			result = p.findall(line)
			if len(result):
				subprocess.Popen('taskkill -PID %s -F'%str(result[1]),shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
# subprocess.Popen('python startmaster.py',shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)

