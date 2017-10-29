local GuideAction424e = class("GuideAction424e", AreaClickAction)

function GuideAction424e:ctor()
    GuideAction424e.super.ctor(self)
    
    self.info = "点击加速"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "accUpBtn"

    self.nextWidget = "nextWidget"
end

function GuideAction424e:onEnter(guide)
    GuideAction424e.super.onEnter(self, guide)
    
end

return GuideAction424e