local GuideAction2441 = class( "GuideAction2441", PlotAction)

function GuideAction2441:ctor()
    GuideAction2441.super.ctor(self)
    self.delayTimePre = 0.5    
    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "太巧了主公，统率刚刚好解锁了！我们赶紧提升下您的带兵数吧。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 2
		  info.head = 10
		  info.name = "玩家名"
		  info.faceIcon = 3
		  info.memo = "带兵数可以干嘛？"
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 4
		  info.memo = "带兵数是单支部队人数，比如带兵数+2，相当于6支部队都加2，总共加了12的带兵数。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
	      info.direction = 2
	      info.head = 14
	      info.name = "玩家名"
	      info.faceIcon = 2
	      info.memo = "原来如此，看来带兵数很重要。"
    table.insert(self._plotData, info)

	local info = {}
		  info.direction = 1
		  info.head = 14
		  info.name = "小婵"
		  info.faceIcon = 2
		  info.memo = "是的，让我们赶紧升级统率，赢得3星战役！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

end

function GuideAction2441:getPlotData()
    return self._plotData
end

function GuideAction2441:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end




return GuideAction2441