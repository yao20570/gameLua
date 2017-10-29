local GuideAction321 = class("GuideAction321", AreaClickAction)

function GuideAction321:ctor()
    GuideAction321.super.ctor(self)
    
    self.info = "升级官邸"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "upBtn"
    self.isShowArrow = false
end

function GuideAction321:onEnter(guide)
    GuideAction321.super.onEnter(self, guide)
    
end

return GuideAction321