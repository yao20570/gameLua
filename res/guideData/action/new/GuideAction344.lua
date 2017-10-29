local GuideAction344 = class("GuideAction344", AreaClickAction)

function GuideAction344:ctor()
    GuideAction344.super.ctor(self)
    
    self.info = "升级兵营"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackBuildPanel"
    self.widgetName = "upBtn"
end

function GuideAction344:onEnter(guide)
    GuideAction344.super.onEnter(self, guide)
    
end

return GuideAction344