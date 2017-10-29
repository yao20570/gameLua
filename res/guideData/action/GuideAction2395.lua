local GuideAction2395 = class( "GuideAction101", AreaClickAction)
function GuideAction2395:ctor(guide)
    GuideAction2395.super.ctor(self)

    self.info = "离开"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city1"

end

function GuideAction2395:onEnter(guide)
    GuideAction2395.super.onEnter(self, guide)
end

return GuideAction2395