local GuideAction405 = class("GuideAction405", AreaClickAction)

function GuideAction405:ctor()
    GuideAction405.super.ctor(self)
    
    self.info = "进入兵营"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel9_2"
end

function GuideAction405:onEnter(guide)
    GuideAction405.super.onEnter(self, guide)
--    guide:hideModule(ModuleName.DungeonModule)
end

return GuideAction405