local GuideAction318 = class("GuideAction318", AreaClickAction)

function GuideAction318:ctor()
    GuideAction318.super.ctor(self)
    
    self.info = "领取完成奖励"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "taskTips"
    -- self.delayTime = 1
    
end

function GuideAction318:onEnter(guide)
    GuideAction318.super.onEnter(self, guide)
end

return GuideAction318