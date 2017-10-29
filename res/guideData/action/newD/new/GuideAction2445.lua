local GuideAction2445 = class( "GuideAction2445", PlotAction)

function GuideAction2445:ctor()
    GuideAction2445.super.ctor(self)

    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "恭喜主公麾下新增猛将！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 2
		  info.memo = "据说猛将令可以获得关羽张飞赵云哦！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 2
		  info.head = 10
		  info.name = "玩家名"
		  info.faceIcon = 3
		  info.memo = "那我只要获得了他们是不是就天下无敌了？"
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 4
		  info.memo = "也不一定哦，武将的核心战斗能力主要是在兵种的搭配上。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
    
	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "如果您上阵的兵种和武将不匹配，是无法发挥出最强的战斗能力的。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "额，你这么说就是单单只有武将还是不够的咯？"
    table.insert(self._plotData, info)

	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "对，先不说那么多，赶紧把于禁上阵了先。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "小婵姑娘带路。"
    table.insert(self._plotData, info)


end


function GuideAction2445:onEnter(guide)
    GuideAction2445.super.onEnter(self, guide)
    
    guide:hideModule(ModuleName.PubModule)
end

function GuideAction2445:getPlotData()
    return self._plotData
end

function GuideAction2445:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end



return GuideAction2445