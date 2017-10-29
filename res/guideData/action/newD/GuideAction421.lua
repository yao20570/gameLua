local GuideAction421 = class("GuideAction421", AreaClickAction)

function GuideAction421:ctor()
    GuideAction421.super.ctor(self)
    
    self.info = "升级官邸"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "upBtn"
    self.isShowArrow = false
end

function GuideAction421:onEnter(guide)
    GuideAction421.super.onEnter(self, guide)
    
end

return GuideAction421