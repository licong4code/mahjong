# coding:utf-8

from Crypto.Cipher import AES  
from Crypto import Random  
import json

PASSWORD = "1111111111111111"
def encrypt(data, password):  
    bs = AES.block_size  
    pad = lambda s: s + (bs - len(s) % bs) * chr(bs - len(s) % bs)  
    iv = Random.new().read(bs)  
    cipher = AES.new(password, AES.MODE_CBC, iv)  
    data = cipher.encrypt(pad(data))  
    data = iv + data  
    return data

def decrypt(data, password):  
    bs = AES.block_size  
    if len(data) <= bs:  
        return data  
    unpad = lambda s : s[0:-ord(s[-1])]  
    iv = data[:bs]  
    cipher = AES.new(password, AES.MODE_CBC, iv)  
    data  = unpad(cipher.decrypt(data[bs:]))  
    return data

class Cryptor:
    @staticmethod
    def encode(data):
    	# return encrypt(json.dumps(data),PASSWORD)
        if data == None:
            return None
        return json.dumps(data)

    @staticmethod
    def decode(data):
    	# return json.loads(decrypt(data,PASSWORD))
        return json.loads(data)

    @staticmethod
    def packResponeData(success,data):
        data = {"code":success,"data":data}
        return json.dumps(data)
