local GuideAction2415 = class( "GuideAction101", AreaClickAction)
function GuideAction2415:ctor(guide)
    GuideAction2415.super.ctor(self)

    self.info = "点击设置阵型"
    self.moduleName = ModuleName.ArenaModule
    self.panelName = "ArenaSqurePanel"
    self.widgetName = "protectBtn"

end

function GuideAction2415:onEnter(guide)
    GuideAction2415.super.onEnter(self, guide)
end

return GuideAction2415