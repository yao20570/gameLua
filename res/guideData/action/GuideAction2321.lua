local GuideAction2321 = class( "GuideAction101", AreaClickAction)
function GuideAction2321:ctor(guide)
    GuideAction2321.super.ctor(self)

    self.info = "点击建筑进行操作"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPanel1_1"  --这里的12跟下面的12一致

end

function GuideAction2321:onEnter(guide)
    GuideAction2321.super.onEnter(self, guide)
end

return GuideAction2321