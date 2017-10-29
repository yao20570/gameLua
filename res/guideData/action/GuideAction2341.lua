local GuideAction2341 = class( "GuideAction101", AreaClickAction)
function GuideAction2341:ctor(guide)
    GuideAction2341.super.ctor(self)

    self.info = "点击建筑进行操作"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel10_4"  --校场

end

function GuideAction2341:onEnter(guide)
    GuideAction2341.super.onEnter(self, guide)
end

return GuideAction2341