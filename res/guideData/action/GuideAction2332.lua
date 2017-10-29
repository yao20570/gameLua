local GuideAction2332 = class( "GuideAction101", AreaClickAction)
function GuideAction2332:ctor(guide)
    GuideAction2332.super.ctor(self)

    self.info = "执行升级操作"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackBuildPanel"
    self.widgetName = "upBtn"
    

end

function GuideAction2332:onEnter(guide)
    GuideAction2332.super.onEnter(self, guide)
end

return GuideAction2332