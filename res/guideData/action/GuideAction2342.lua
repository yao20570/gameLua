local GuideAction2342 = class( "GuideAction101", AreaClickAction)
function GuideAction2342:ctor(guide)
    GuideAction2342.super.ctor(self)

    self.info = "执行升级操作"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackBuildPanel"
    self.widgetName = "upBtn"

end

function GuideAction2342:onEnter(guide)
    GuideAction2342.super.onEnter(self, guide)
end

return GuideAction2342