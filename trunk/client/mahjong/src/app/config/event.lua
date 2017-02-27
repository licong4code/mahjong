--[[
excel file:	event.xlsx

id:指令
action:方法名
ok:成功回调
no:失败回调
desc:描述
]]

return {
["1000"]={
	["id"] = "1000",
	["action"] = "connect",
	["ok"] = "connectSuccess",
	["no"] = "connectFail",
	["desc"] = "链接服务器"
},
["1001"]={
	["id"] = "1001",
	["action"] = "login",
	["ok"] = "loginSuccess",
	["no"] = "loginFail",
	["desc"] = "登录"
},
["1002"]={
	["id"] = "1002",
	["action"] = "logout",
	["desc"] = "退出登录"
},
["1003"]={
	["id"] = "1003",
	["action"] = "buildRoom",
	["ok"] = "buildRoomSuccess",
	["no"] = "buildRoomFail",
	["desc"] = "创建房间"
},
["1004"]={
	["id"] = "1004",
	["action"] = "enterRoom",
	["ok"] = "enterRoomSuccess",
	["no"] = "enterRoomFail",
	["desc"] = "进入房间"
},
["1005"]={
	["id"] = "1005",
	["action"] = "request",
	["ok"] = "exitRoomSuccess",
	["desc"] = "退出房间"
},
["1006"]={
	["id"] = "1006",
	["action"] = "dissolveRoom",
	["ok"] = "onDissolveSuccess",
	["no"] = "dissolveFail",
	["desc"] = "解散房间"
},
["1007"]={
	["id"] = "1007",
	["action"] = "applyDissolveRoom",
	["ok"] = "applyDissolveSuccess",
	["no"] = "applyDissolveFail",
	["desc"] = "申请解散"
},
["1008"]={
	["id"] = "1008",
	["action"] = "responseDissolve",
	["desc"] = "响应解散申请"
},
["1009"]={
	["id"] = "1009",
	["action"] = "request",
	["ok"] = "outOK",
	["desc"] = "出牌"
},
["1010"]={
	["id"] = "1010",
	["action"] = "request",
	["ok"] = "pengOK",
	["desc"] = "碰牌"
},
["1011"]={
	["id"] = "1011",
	["action"] = "request",
	["ok"] = "gangOK",
	["desc"] = "杠（）"
},
["1012"]={
	["id"] = "1012",
	["action"] = "request",
	["ok"] = "huOK",
	["desc"] = "胡牌"
},
["1013"]={
	["id"] = "1013",
	["action"] = "request",
	["desc"] = "放弃"
},
["2000"]={
	["id"] = "2000",
	["ok"] = "onUserEnter",
	["desc"] = "玩家进入房间"
},
["2001"]={
	["id"] = "2001",
	["ok"] = "onUserExit",
	["desc"] = "玩家退出房间"
},
["2002"]={
	["id"] = "2002",
	["ok"] = "onOtherUserLostConnect",
	["desc"] = "玩家掉线"
},
["2003"]={
	["id"] = "2003",
	["ok"] = "onApplyDissolve",
	["desc"] = "申请解散"
},
["2007"]={
	["id"] = "2007",
	["desc"] = "玩家已经拿牌（提示其他玩家）"
},
["2008"]={
	["id"] = "2008",
	["ok"] = "onUserIn",
	["desc"] = "拿牌"
},
["2009"]={
	["id"] = "2009",
	["ok"] = "onUserOut",
	["desc"] = "玩家出牌"
},
["2010"]={
	["id"] = "2010",
	["ok"] = "onUserPeng",
	["desc"] = "玩家碰牌"
},
["2011"]={
	["id"] = "2011",
	["ok"] = "onUserGang",
	["desc"] = "玩家杠"
},
["2012"]={
	["id"] = "2012",
	["ok"] = "onUserHu",
	["desc"] = "玩家胡牌"
},
["2100"]={
	["id"] = "2100",
	["ok"] = "onDropLine",
	["desc"] = "异地登录（下线）"
}
}