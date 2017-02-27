# coding:
import subprocess,re
for port in (1234,):
	res = subprocess.Popen('lsof -i tcp:%d'%port,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,close_fds=True)  
	result = res.stdout.readlines()
	p = re.compile(r'\d{3,5}')
	for line in result:
		result = p.findall(line)
		if len(result):
			subprocess.Popen('kill -9 %s'%str(result[0]),shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,close_fds=True)


# subprocess.Popen('python startmaster.py',shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)