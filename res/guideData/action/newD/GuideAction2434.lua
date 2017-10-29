local GuideAction2434 = class( "GuideAction2434", PlotAction) -- 替换414

function GuideAction2434:ctor()
    GuideAction2434.super.ctor(self)

    self.delayTimePre = 0.5  

    self._plotData = {}

    local info = {}
          info.direction = 1
          info.head = 1
          info.name = "小婵"
          info.faceIcon = 1
          info.memo = "主公，讨伐黄巾贼会有5%损兵，受伤的5%士兵会进入伤兵营。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
          info.direction = 2
          info.head = 14
          info.name = "玩家名"
          info.faceIcon = 2
          info.memo = "无妨，只要用银币买点药治疗，立马就能归队，让我们先讨伐低级黄巾军。"
    table.insert(self._plotData, info)

    local info = {}
          info.direction = 1
          info.head = 1
          info.name = "小婵"
          info.faceIcon = 3
          info.memo = "明白了，主公，我们即刻全军出击，一举击溃他们！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

end


function GuideAction2434:getPlotData()
    return self._plotData
end

function GuideAction2434:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end

return GuideAction2434