local GuideAction305 = class("GuideAction305", AreaClickAction)

function GuideAction305:ctor()
    GuideAction305.super.ctor(self)
    
    self.info = "进入兵营"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel9_2"
end

function GuideAction305:onEnter(guide)
    GuideAction305.super.onEnter(self, guide)
--    guide:hideModule(ModuleName.DungeonModule)
end

return GuideAction305