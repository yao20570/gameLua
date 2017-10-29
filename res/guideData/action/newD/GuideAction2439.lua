local GuideAction2439 = class( "GuideAction2439", PlotAction) -- 437

function GuideAction2439:ctor()
    GuideAction2439.super.ctor(self)
    self.delayTimePre = 0.5   
    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "战役只是一个试练，不会造成任何的伤兵和损兵，主公请任性挑战吧！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 2
		  info.head = 10
		  info.name = "玩家名"
		  info.faceIcon = 3
		  info.memo = "我发现战役可以获得大量经验，肯定能让我的等级提升的更快一些！"
    table.insert(self._plotData, info)
    
	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "主公真聪慧！如果您搭配16级的太学院解锁的经验科技，简直就是飞起！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "原来如此，让我试试看。"
    table.insert(self._plotData, info)


end

function GuideAction2439:getPlotData()
    return self._plotData
end

function GuideAction2439:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end




return GuideAction2439