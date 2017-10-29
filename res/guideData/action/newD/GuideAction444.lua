local GuideAction444 = class("GuideAction444", AreaClickAction)

function GuideAction444:ctor()
    GuideAction444.super.ctor(self)
    
    self.info = "升级兵营"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackBuildPanel"
    self.widgetName = "upBtn"
end

function GuideAction444:onEnter(guide)
    GuideAction444.super.onEnter(self, guide)
    
end

return GuideAction444