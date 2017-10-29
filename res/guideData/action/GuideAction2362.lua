local GuideAction2362 = class( "GuideAction101", AreaClickAction)
function GuideAction2362:ctor(guide)
    GuideAction2362.super.ctor(self)

    self.info = "执行升级操作"
    self.moduleName = ModuleName.ScienceMuseumModule
    self.panelName = "ScienceBuildPanel"
    self.widgetName = "upBtn"

end

function GuideAction2362:onEnter(guide)
    GuideAction2362.super.onEnter(self, guide)
end

return GuideAction2362