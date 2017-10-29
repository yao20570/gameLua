local GuideAction115 = class("GuideAction115", AreaClickAction)

function GuideAction115:ctor()
    GuideAction115.super.ctor(self)
    
    self.info = "有了装备，记得来将军府穿戴"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel13_6"
    self.isShowArrow = false
end

function GuideAction115:onEnter(guide)
    GuideAction115.super.onEnter(self, guide)
--    guide:hideModule(ModuleName.DungeonModule)
end

return GuideAction115