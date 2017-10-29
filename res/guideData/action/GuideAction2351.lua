local GuideAction2351 = class( "GuideAction101", AreaClickAction)
function GuideAction2351:ctor(guide)
    GuideAction2351.super.ctor(self)

    self.info = "点击建筑进行操作"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel7_9"  --仓库

end

function GuideAction2351:onEnter(guide)
    GuideAction2351.super.onEnter(self, guide)
end

return GuideAction2351