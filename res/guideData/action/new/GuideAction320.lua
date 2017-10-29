local GuideAction320 = class("GuideAction320", AreaClickAction)

function GuideAction320:ctor()
    GuideAction320.super.ctor(self)
    
    self.info = "进入官邸"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel1_1"
    self.isShowArrow = false
end

function GuideAction320:onEnter(guide)
    GuideAction320.super.onEnter(self, guide)
end

return GuideAction320