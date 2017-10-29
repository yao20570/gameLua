local GuideAction2433 = class( "GuideAction2433", PlotAction) -- 替换403

function GuideAction2433:ctor()
    GuideAction2433.super.ctor(self)

    self.delayTimePre = 0.5

    self._plotData = {}


    local info = {}
          info.direction = 2
          info.head = 3
          info.name = "百姓"
          info.faceIcon = 2
          info.memo = "大人！大人！救救我们！"
    table.insert(self._plotData, info)

    local info = {}
          info.direction = 1
          info.head = 1
          info.name = "小婵"
          info.faceIcon = 3
          info.memo = "老人家，何事惊慌？"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
    
	local info = {}
          info.direction = 2
          info.head = 3
          info.name = "百姓"
          info.faceIcon = 2
          info.memo = "黄巾余党杀人放火、掠夺钱粮，我女儿还在他们手上，请大人替我等剿灭流匪！"
    table.insert(self._plotData, info)
    
	local info = {}
          info.direction = 2
          info.head = 14
          info.name = "玩家名"
          info.faceIcon = 2
          info.memo = "乱贼甚是可恶，即刻入城征召士兵，全军剿匪！"
    table.insert(self._plotData, info)

end

--function GuideAction2433:onEnter(guide)
--    GuideAction2433.super.onEnter(self, guide)
--end

function GuideAction2433:getPlotData()
    return self._plotData
end

function GuideAction2433:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end

return GuideAction2433