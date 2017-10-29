local GuideAction418 = class("GuideAction418", AreaClickAction)

function GuideAction418:ctor()
    GuideAction418.super.ctor(self)
    
    self.info = "领取完成奖励"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "taskTips"
    self.delayTime = 1
    
end

function GuideAction418:onEnter(guide)
    GuideAction418.super.onEnter(self, guide)
    guide:hideModule(ModuleName.HeroModule)
end

return GuideAction418