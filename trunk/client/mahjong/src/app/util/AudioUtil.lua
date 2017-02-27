--[[
	date:2015-04-10
	
	AudioUtil 声音工具类

]]

local AudioUtil = {}
AudioUtil.SoundGapSet = {}

--游戏背景音乐
AudioUtil.bg = {
				["logo"]="sound/bg/logo",
				-- ["1-1"]="sound/bg/1-1",
				-- ["2-1"]="sound/bg/2-1",
				-- ["3-1"]="sound/bg/3-1",
				-- ["4-1"]="sound/bg/1-1",
				-- ["5-1"]="sound/bg/1-1",
				-- ["6-1"]="sound/bg/1-1",
				-- ["7-1"]="sound/bg/1-1",
			}

-- 游戏配音
AudioUtil.soundfix = {
					[20]="sound/1/20",		--公司logo
--					[21]="sound/1/21",		--选关界面，点击进入
--					[22]="sound/1/22",      --选关界面，选中关卡
				}

-- 游戏音效
AudioUtil.soundEffect = {
						[2]="sound/2/2",	--滑翔
						[3]="sound/2/3",	--脚步
						[4]="sound/2/4",	--跳跃
						[5]="sound/2/5",	--剑特效
						[6]="sound/2/6",	--刀特效
						[7]="sound/2/7",	--出鞘
						[8]="sound/2/8",	--剑防御
						[9]="sound/2/9",	--下雨声音
						[10]="sound/2/10",	--狼boss特技
						[11]="sound/2/11",	--触发音效（感叹号）
						[12]="sound/2/12",	--武器能量条蓄满
						[13]="sound/2/13",	--扣除体力
                        [14]="sound/2/14",	--主角落地
                        [15]="sound/2/15",	--跑步停止后滑步
                        [16]="sound/2/16",	--断刀
                        [17]="sound/2/17",	--点击进入按钮
                        [18]="sound/2/18",	--选关
                        [19]="sound/2/19",	--任务浮框
                        [20]="sound/2/20",	--金币结算
					}

--音乐
AudioUtil.music =
{
	
}

--音效
AudioUtil.sound =
{
	-- [1] = "sound/s/10001", 						--角色移动
	-- [2] = "sound/s/10008", 						--角色普通攻击1
	-- [3] = "sound/s/10009", 						--角色普通攻击2
	-- [4] = "sound/s/10010", 						--角色普通攻击3
	-- [5] = "sound/s/10011", 						--角色普通攻击4
	-- [6] = "sound/s/10012", 						--角色普通攻击5
	-- [7] = "sound/s/10002", 						--角色落地
	-- [8] = "sound/s/10003", 						--角色跳跃
	-- [9] = "sound/s/10004", 						--角色受击
	-- [10] = "sound/s/103", 						--角色死亡
	-- [11] = "sound/s/20006", 					--角色投掷暗器
	-- -- [12] = "sound/s/20001", 					--敌人攻击
	-- [13] = "sound/s/20008", 					--机关人受击
	[14] = "sound/s/14", 						--商城购买
	-- [15] = "sound/s/20002", 					--杀手射箭
	-- [16] = "sound/s/20007", 					--挥鞭子
	-- [17] = "sound/s/20005", 					--狼冲锋
	-- [18] = "sound/s/10015", 					--火符
	-- [19] = "sound/s/10016", 					--冰雨

	-- [20] = "sound/s/20010", 				--石头落地
	-- [21] = "sound/s/204", 					--男杀手死
	-- [22] = "sound/s/208", 					--神秘人头领死
	-- [23] = "sound/s/212", 					--狼BOSS死
	-- [24] = "sound/s/214", 					--驯兽师死

	--UI音效
	[25] = "sound/s/8", 					--确定
	[26] = "sound/s/9", 					--取消
	[27] = "sound/s/10", 					--切换

	-- [28] = "sound/s/102", 					--主角受击
	[30] = "sound/s/10101", 				--二段跳
	[31] = "sound/s/10005", 				--换武器
	-- [32] = "sound/s/108", 					--攻击最后一下
	[33] = "sound/s/11", 					--获得草药
	[34] = "sound/s/12", 					--称号谱界面领取称号奖励、任务界面领取奖励
	[35] = "sound/s/13", 					--剑、暗器升级
}

--播放音效列表
AudioUtil.playSoundList = function (sdlist)
	for i,v in ipairs(sdlist or {}) do
		audio.playSound(v)
	end
end

--带间隔的播放音效列表
AudioUtil.playSoundListWidthGap = function (sdlist, gap)
	gap = gap or 1
	for i,v in ipairs(sdlist or {}) do
		AudioUtil.playSoundWidthGap(v, gap)
	end
end

--带间隔的播放音效
AudioUtil.playSoundWidthGap = function (sd, gap)
	local last = AudioUtil.SoundGapSet[sd]
	local now = Util.getCurTime()
	gap = gap or 1
	if last and now - last < gap then
		return
	end
	audio.playSound(sd)
	AudioUtil.SoundGapSet[sd] = now
end

return AudioUtil