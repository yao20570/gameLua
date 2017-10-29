local GuideAction2432 = class( "GuideAction2432", PlotAction) -- 替换401

function GuideAction2432:ctor()
    GuideAction2432.super.ctor(self)

    self.delayTimePre = 0.5 


    self._plotData = {}


    local info = {}
          info.direction = 2
          info.head = 14
          info.name = "玩家名"
          info.faceIcon = 2
          info.memo = "虽说董贼已败，但黄巾之乱尚未停息，我们赶紧回城了解百姓现在的情况。"
    table.insert(self._plotData, info)

    local info = {}
          info.direction = 1
          info.head = 1
          info.name = "小婵"
          info.faceIcon = 3
          info.memo = "好的，赶紧入城，看看我们的百姓怎么样了。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
end

function GuideAction2432:onEnter(guide)
    GuideAction2432.super.onEnter(self, guide)

    guide:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.MapModule, isPerLoad = true})

    local forxy = guide:getProxy(GameProxys.Dungeon)
    forxy:onTriggerNet60001Req({id = 101})   --TODO 这里要请求第一个
end

function GuideAction2432:getPlotData()
    return self._plotData
end

function GuideAction2432:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end

function GuideAction2432:callback(value)
    GuideAction2432.super.callback(self, value)

    logger:error("CallBack IN IsNextAction : ".. (self._isNextAction and "true" or "false"))
end

return GuideAction2432
