local GuideAction324e1 = class("GuideAction324e1", AreaClickAction)

function GuideAction324e1:ctor()
    GuideAction324e1.super.ctor(self)
    
    self.info = "点击加速"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "accQuickBtn"

    self.nextWidget = "nextAccWidget"
end

function GuideAction324e1:onEnter(guide)
    GuideAction324e1.super.onEnter(self, guide)
    
end

return GuideAction324e1