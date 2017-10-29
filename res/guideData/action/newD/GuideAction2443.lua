local GuideAction2443 = class( "GuideAction2443", PlotAction)

function GuideAction2443:ctor()
    GuideAction2443.super.ctor(self)
    self.delayTimePre = 0.5
    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "敌方出动大量刀兵，主公，兵种之间是有克制关系的！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
	
    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "克制关系 -> 骑 克 刀    刀 克 弓    弓 克 枪   枪 克 骑。 "
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
         
    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 3
		  info.memo = "我们派遣骑兵对刀兵可以额外造成25%的伤害哦！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
          
	local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "那我们现在赶紧去训练一批骑兵出来！"
    table.insert(self._plotData, info)

end

function GuideAction2443:getPlotData()
    return self._plotData
end

function GuideAction2443:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end

function GuideAction2443:callback(value)
    GuideAction2443.super.callback(self, value)

    local module = self._guide:getModule(ModuleName.DungeonModule)
    module.srcModule = nil --清除掉来源关系
    self._guide:hideModule(ModuleName.DungeonModule)
    self._guide:hideModule(ModuleName.RegionModule)
end


return GuideAction2443