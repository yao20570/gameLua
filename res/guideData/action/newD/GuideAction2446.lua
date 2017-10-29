local GuideAction2446 = class( "GuideAction2446", PlotAction)

function GuideAction2446:ctor()
    GuideAction2446.super.ctor(self)
    self.deleyTime = 1
    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "主公，军师府有要事需要前往帮忙，军师府28级解锁后，到时我们就可以朝夕相处啦。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "主公您先跟着主线走升级更快哦，8级解锁同盟，各路英雄豪杰等着您呢！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
	
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "多谢姑娘一路帮忙！"
    table.insert(self._plotData, info)

end

function GuideAction2446:getPlotData()
    return self._plotData
end

function GuideAction2446:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end



return GuideAction2446