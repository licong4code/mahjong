# coding:utf-8
''' 
	Created by licong on 2016/12/09.

'''


from firefly.utils.services import CommandService
from twisted.python import log
from twisted.internet import defer

from encrypt import Cryptor


def DefferedErrorHandle(e):
    '''延迟对象的错误处理'''
    log.err(str(e))
    return

# def callback(data,conn,command):
#     print conn.user.id,conn.transport.connected,command,data
#     conn.safeToWriteData(data,command)

class LocalService(CommandService):
    
    def callTargetSingle(self,targetKey,conn,data,*args,**kw):
        '''call Target by Single
        @param conn: client connection
        @param targetKey: target ID
        @param data: client data
        '''
        
        self._lock.acquire()
        try:
            target = self.getTarget(targetKey)
            if not target:
                log.err('the command '+str(targetKey)+' not Found on service')
                return None
            if targetKey not in self.unDisplay:
                log.msg("call method %s on service[single]"%target.__name__)
            defer_data = target(conn,Cryptor.decode(data),*args,**kw)
            if not defer_data:
                return None
            if isinstance(defer_data,defer.Deferred):
                return defer_data

            d = defer.Deferred()
            d.callback(Cryptor.encode(defer_data))
        finally:
            self._lock.release()
        return d

    def sendMessage(self,conn,data,command):
        self._lock.acquire()
        try:
            d = defer.Deferred()
            d.callback(Cryptor.encode(data))
            d.addCallback(conn.safeToWriteData,command)
            # d.addCallback(callback,conn,command)
            d.addErrback(DefferedErrorHandle)
        finally:
            self._lock.release()