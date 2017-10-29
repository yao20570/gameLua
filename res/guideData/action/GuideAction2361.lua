local GuideAction2361 = class( "GuideAction101", AreaClickAction)
function GuideAction2361:ctor(guide)
    GuideAction2361.super.ctor(self)

    self.info = "点击建筑进行操作"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel8_12"  --太学院

end

function GuideAction2361:onEnter(guide)
    GuideAction2361.super.onEnter(self, guide)
end

return GuideAction2361