# !/usr/bin/python
# coding:utf-8

import os,hashlib,json
from shutil import copytree, ignore_patterns,rmtree
from pack import Packer,DealResource

CURDIR = os.path.split(os.path.realpath(__file__))[0]
NAME = "fileinfo.txt"

serveroot = os.path.join(CURDIR,"../trunk/serve/code/hotUpdateServer/root/game")
game_root = os.path.join(CURDIR,"../trunk/client/mahjong")
# make root
if os.path.exists(serveroot):
	rmtree(serveroot)
os.mkdir(serveroot)

# copy

for dirname in ("res","src"):
	copytree(os.path.join(game_root,dirname), os.path.join(serveroot,dirname), ignore=ignore_patterns('*.pyc', 'tmp*'))


instance = Packer(game_root,None,"android",None)
instance.updateVersion()
instance.encryptCode(os.path.join(serveroot,"src"),os.path.join(serveroot,"res"))

deal = DealResource(serveroot)
deal.run()