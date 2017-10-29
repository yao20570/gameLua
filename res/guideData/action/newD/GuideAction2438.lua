local GuideAction2438 = class( "GuideAction2438", PlotAction) -- 433

function GuideAction2438:ctor()
    GuideAction2438.super.ctor(self)
    self.delayTimePre = 0.5    
    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "主公的名望已经传播开了，赶紧前往战役挑战吧！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "挑战战役可以干嘛？"
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "挑战战役需要消耗军令，战胜后可获得经验，更可能获得武将魂。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 4
		  info.memo = "凑齐武将魂可以招募精兵猛将，比如：五虎将，五子良将等。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "那我们赶紧前往挑战呀！"
    table.insert(self._plotData, info)
	
end

function GuideAction2438:getPlotData()
    return self._plotData
end

function GuideAction2438:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end




return GuideAction2438