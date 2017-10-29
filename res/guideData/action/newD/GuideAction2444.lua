local GuideAction2444 = class( "GuideAction2444", PlotAction)

function GuideAction2444:ctor()
    GuideAction2444.super.ctor(self)

    self._plotData = {}

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 1
		  info.memo = "太棒了，终于凑到12颗星星，可以领取战役宝箱啦！"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 2
		  info.memo = "战役宝箱一般会给女儿红和元宝。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)

    local info = {}
		  info.direction = 2
		  info.head = 10
		  info.name = "玩家名"
		  info.faceIcon = 3
		  info.memo = "女儿红我知道是什么！可以前往酒馆用来招兵募将。"
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 1
		  info.head = 1
		  info.name = "小婵"
		  info.faceIcon = 4
		  info.memo = "那我们还等什么？"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)


end

function GuideAction2444:getPlotData()
    return self._plotData
end

function GuideAction2444:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end



return GuideAction2444