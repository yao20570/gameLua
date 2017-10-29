local GuideAction2322 = class( "GuideAction101", AreaClickAction)
function GuideAction2322:ctor(guide)
    GuideAction2322.super.ctor(self)

    self.info = "执行升级操作"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "upBtn"

end

function GuideAction2322:onEnter(guide)
    GuideAction2322.super.onEnter(self, guide)
end

return GuideAction2322