local GuideAction2412 = class( "GuideAction101", AreaClickAction)
function GuideAction2412:ctor(guide)
    GuideAction2412.super.ctor(self)

    self.info = "点击最大战力"
    self.moduleName = ModuleName.ArenaModule
    self.panelName = "ArenaSqurePanel"
    self.widgetName = "maxFightBtn"

end

function GuideAction2412:onEnter(guide)
    GuideAction2412.super.onEnter(self, guide)
end

return GuideAction2412