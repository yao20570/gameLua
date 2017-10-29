local GuideAction352 = class("GuideAction352", AreaClickAction)

function GuideAction352:ctor()
    GuideAction352.super.ctor(self)
    
    self.info = "点击返回"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "closeBtn"
end

function GuideAction352:onEnter(guide)
    GuideAction352.super.onEnter(self, guide)
    
end

return GuideAction352