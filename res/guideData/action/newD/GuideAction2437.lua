local GuideAction2437 = class( "GuideAction2437", PlotAction) -- 425

function GuideAction2437:ctor()
    GuideAction2437.super.ctor(self)

    self.delayTimePre = 0.5     

    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "主公，手速不错嘛！免费点得很溜哦！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 2
		  info.head = 14
		  info.name = "玩家名"
		  info.faceIcon = 2
		  info.memo = "多亏婵儿姑娘的悉心指点。"
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 1
		  info.head = 3
		  info.name = "百姓"
		  info.faceIcon = 3
		  info.memo = "主公，您把我们的国家建设得真棒，这是一份心意，希望能帮到您。"
    table.insert(self._plotData, info)


end

function GuideAction2437:getPlotData()
    return self._plotData
end

function GuideAction2437:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end


function GuideAction2437:callback(value)
    GuideAction2437.super.callback(self, value)
    self._guide:hidePanel(ModuleName.MainSceneModule, "BuildingUpPanel")
end

return GuideAction2437