local GuideAction324e = class("GuideAction324e", AreaClickAction)

function GuideAction324e:ctor()
    GuideAction324e.super.ctor(self)
    
    self.info = "点击加速"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "accUpBtn"

    self.nextWidget = "nextWidget"
end

function GuideAction324e:onEnter(guide)
    GuideAction324e.super.onEnter(self, guide)
    
end

return GuideAction324e