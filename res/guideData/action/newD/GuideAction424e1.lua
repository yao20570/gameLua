local GuideAction424e1 = class("GuideAction424e1", AreaClickAction)

function GuideAction424e1:ctor()
    GuideAction424e1.super.ctor(self)
    
    self.info = "点击加速"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "accFreeBtn"

    self.nextWidget = "nextAccWidget"
end

function GuideAction424e1:onEnter(guide)
    GuideAction424e1.super.onEnter(self, guide)
    
end

return GuideAction424e1