local GuideAction2440 = class( "GuideAction2440", PlotAction)

function GuideAction2440:ctor()
    GuideAction2440.super.ctor(self)

    self.delayTimePre = 0.5     

    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "敌军部队数量有点太多，我们先回城商讨下对策。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "部队不足是不是征召士兵就好了？"
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "感觉带兵数还不够，先回城与百姓商策下。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
    
end

function GuideAction2440:onEnter(guide)
    GuideAction2440.super.onEnter(self, guide)
end

function GuideAction2440:getPlotData()
    return self._plotData
end

function GuideAction2440:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end

function GuideAction2440:callback(value)
    GuideAction2440.super.callback(self, value)

    local module = self._guide:getModule(ModuleName.DungeonModule)
    module.srcModule = nil --清除掉来源关系
    self._guide:hideModule(ModuleName.DungeonModule)
    self._guide:hideModule(ModuleName.RegionModule)
end


return GuideAction2440