local GuideAction345 = class("GuideAction345", AreaClickAction)

function GuideAction345:ctor()
    GuideAction345.super.ctor(self)
    
    self.info = "免费加速，立即完成"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackBuildPanel"
    self.widgetName = "quickBtn"
end

function GuideAction345:onEnter(guide)
    GuideAction345.super.onEnter(self, guide)
    
end

return GuideAction345