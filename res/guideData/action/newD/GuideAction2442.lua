local GuideAction2442 = class( "GuideAction2442", PlotAction)

function GuideAction2442:ctor()
    GuideAction2442.super.ctor(self)
    self.delayTimePre = 0.5
    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "主公带兵能力突飞猛进，现在我们还差6个星星就能领取宝箱。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 2
		  info.memo = "战役宝箱里面都是好东西哦，我们继续挑战吧！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 4
		  info.memo = "好的，没问题!"
    table.insert(self._plotData, info)


end

function GuideAction2442:getPlotData()
    return self._plotData
end

function GuideAction2442:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end




return GuideAction2442