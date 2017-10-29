local GuideAction2403 = class( "GuideAction101", AreaClickAction)
function GuideAction2403:ctor(guide)
    GuideAction2403.super.ctor(self)

    self.info = "点击“民心”按钮"
    self.moduleName = ModuleName.RegionModule
    self.panelName = "CenterRegionPanel"
    self.widgetName = "peopleBtn"

end

function GuideAction2403:onEnter(guide)
    GuideAction2403.super.onEnter(self, guide)
end

return GuideAction2403