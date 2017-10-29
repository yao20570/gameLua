local GuideAction452 = class("GuideAction452", AreaClickAction)

function GuideAction452:ctor()
    GuideAction452.super.ctor(self)
    
    self.info = "点击返回"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "closeBtn"
end

function GuideAction452:onEnter(guide)
    GuideAction452.super.onEnter(self, guide)
    
end

return GuideAction452