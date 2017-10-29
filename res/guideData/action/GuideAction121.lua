local GuideAction121 = class("GuideAction121", AreaClickAction)

function GuideAction121:ctor()
    GuideAction121.super.ctor(self)
    
    self.info = "兵营中可征召步兵"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel9_2"
    self.isShowArrow = false
end

function GuideAction121:onEnter(guide)
    GuideAction121.super.onEnter(self, guide)
--    guide:hideModule(ModuleName.DungeonModule)
end

return GuideAction121