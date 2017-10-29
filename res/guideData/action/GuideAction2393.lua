local GuideAction2393 = class( "GuideAction101", AreaClickAction)
function GuideAction2393:ctor(guide)
    GuideAction2393.super.ctor(self)

    self.info = "点击远征"
    self.moduleName = ModuleName.RegionModule
    self.panelName = "CenterRegionPanel"
    self.widgetName = "expeditionBtn"

end

function GuideAction2393:onEnter(guide)
    GuideAction2393.super.onEnter(self, guide)
end

return GuideAction2393