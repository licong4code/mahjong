--
-- Author: Alex
-- Date: 2015-05-11 15:25:25
--
local EventCenter = class("EventCenter")

function EventCenter:ctor()
	EventMgr:addEventListener(GB_EVENT_GAME_WIN, handler(self, self.onGameWin))
end

function EventCenter:onGameWin(event)
	-- print('---------------onGameWin---------------')
	globalRole:victory()
end

return EventCenter