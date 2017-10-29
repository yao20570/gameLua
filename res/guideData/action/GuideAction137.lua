local GuideAction137 = class("GuideAction137", AreaClickAction)

function GuideAction137:ctor()
    GuideAction137.super.ctor(self)
    
    self.info = "领取任务奖励"
    self.moduleName = ModuleName.TaskModule
    self.panelName = "MainTaskPanel"
    self.widgetName = "rewardBtn1"
    self.isShowArrow = false
end

function GuideAction137:onEnter(guide)
    GuideAction137.super.onEnter(self, guide)
end

return GuideAction137