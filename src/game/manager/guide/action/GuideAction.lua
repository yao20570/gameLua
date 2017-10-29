GuideAction = class("GuideAction")

function GuideAction:ctor()
    self._guide = nil
    
    self.info = ""
    self.moduleName = nil
    self.panelName = nil
    self.widgetName = nil

    self.nextWidget = nil --如果获取到这个Widget，则直接进入下一步
    
    self.delayNextActionTime = 0  --单位秒 引导步骤结束后延迟多少时间到下一步
    self.delayTimePre = 0 --单位秒  延迟多少时间到这一步引导
    self.defaultAutoNextAction = 3
    self.delayTime = nil -- 下一步引导出现的时间

    self.autoNextAction = 3 --自动下一Action
    self.callbackArg = nil

    self.delayFlyTime = 100--物品飘窗延迟时间
    
    self.isFinalize = false
end

function GuideAction:finalize()
    self.isFinalize = true
end

function GuideAction:onEnter(guide)
    GameConfig.guideParams.DELAY_FLY_TIME = self.delayFlyTime or GameConfig.guideParams.DELAY_TIME
    self._guide = guide
    self._taskList = {}
    self.defaultAutoNextAction = 8
    guide:show()
end

function GuideAction:nextAction()
    self._guide:resetGuideView()
    self._guide:nextAction()
end

function GuideAction:sendNotification(mainevent, subevent, data)
    self._guide:sendNotification(mainevent, subevent, data)
end