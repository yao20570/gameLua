local GuideAction2352 = class( "GuideAction101", AreaClickAction)
function GuideAction2352:ctor(guide)
    GuideAction2352.super.ctor(self)

    self.info = "执行升级操作"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "upBtn"

end

function GuideAction2352:onEnter(guide)
    GuideAction2352.super.onEnter(self, guide)
end

return GuideAction2352