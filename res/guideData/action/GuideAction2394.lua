local GuideAction2394 = class( "GuideAction101", AreaClickAction)
function GuideAction2394:ctor(guide)
    GuideAction2394.super.ctor(self)

    self.info = "点击匈奴"
    self.moduleName = ModuleName.RegionModule
    self.panelName = "RegionPanel"
    self.widgetName = "asiaPanel1"

end

function GuideAction2394:onEnter(guide)
    GuideAction2394.super.onEnter(self, guide)
end

return GuideAction2394