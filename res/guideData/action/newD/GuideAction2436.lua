local GuideAction2436 = class( "GuideAction2436", PlotAction)

function GuideAction2436:ctor()
    GuideAction2436.super.ctor(self)

    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "主公，官邸是主城发展的首要任务，官邸等级是其他建筑的升级条件。特别是兵营哦！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 2
		  info.head = 10
		  info.name = "玩家名"
		  info.faceIcon = 3
		  info.memo = "行，让我们拉起袖子好好干！"
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 4
		  info.memo = "还有，当建设时间剩余5分钟内可以免费加速！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 4
		  info.memo = "超过5分钟的话只能等吗？"
    table.insert(self._plotData, info)
    
	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "讨伐黄巾贼可获得建筑加速卡，刚主公就有获得建设加速卡，赶紧使用试试。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "婵儿姑娘请指路！"
    table.insert(self._plotData, info)


end

function GuideAction2436:getPlotData()
    return self._plotData
end

function GuideAction2436:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end



return GuideAction2436