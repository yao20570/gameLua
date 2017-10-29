local GuideAction445 = class("GuideAction445", AreaClickAction)

function GuideAction445:ctor()
    GuideAction445.super.ctor(self)
    
    self.info = "免费加速，立即完成"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackBuildPanel"
    self.widgetName = "quickBtn"
end

function GuideAction445:onEnter(guide)
    GuideAction445.super.onEnter(self, guide)
    
end

return GuideAction445