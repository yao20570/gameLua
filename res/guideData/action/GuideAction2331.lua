local GuideAction2331 = class( "GuideAction101", AreaClickAction)
function GuideAction2331:ctor(guide)
    GuideAction2331.super.ctor(self)

    self.info = "点击建筑进行操作"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel9_2"  --兵营

end

function GuideAction2331:onEnter(guide)
    GuideAction2331.super.onEnter(self, guide)
end

return GuideAction2331