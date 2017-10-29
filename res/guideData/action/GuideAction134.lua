local GuideAction134 = class("GuideAction134", AreaClickAction)

function GuideAction134:ctor()
    GuideAction134.super.ctor(self)
    
    self.info = "官邸是其他建筑升级的前提"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel1_1"
    self.isShowArrow = false
end

function GuideAction134:onEnter(guide)
    GuideAction134.super.onEnter(self, guide)
end

return GuideAction134