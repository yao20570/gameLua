local GuideAction420 = class("GuideAction420", AreaClickAction)

function GuideAction420:ctor()
    GuideAction420.super.ctor(self)
    
    self.info = "进入官邸"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel1_1"
    self.isShowArrow = false
end

function GuideAction420:onEnter(guide)
    GuideAction420.super.onEnter(self, guide)
end

return GuideAction420