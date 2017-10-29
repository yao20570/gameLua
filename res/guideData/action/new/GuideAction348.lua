local GuideAction348 = class("GuideAction348", AreaClickAction)

function GuideAction348:ctor()
    GuideAction348.super.ctor(self)
    
    self.info = "征召士兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "tabBtn2"  --中间标签
end

function GuideAction348:onEnter(guide)
    GuideAction348.super.onEnter(self, guide)
    
end

return GuideAction348