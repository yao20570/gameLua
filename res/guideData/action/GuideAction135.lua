local GuideAction135 = class("GuideAction135", AreaClickAction)

function GuideAction135:ctor()
    GuideAction135.super.ctor(self)
    
    self.info = "升级官邸，建造高级建筑"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "upBtn"
    self.isShowArrow = false
end

function GuideAction135:onEnter(guide)
    GuideAction135.super.onEnter(self, guide)
    
--    guide:hidePanel(ModuleName.MainSceneModule, "BuildingUpPanel")
end

return GuideAction135