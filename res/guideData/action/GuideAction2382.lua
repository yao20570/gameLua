local GuideAction2382 = class( "GuideAction101", AreaClickAction)
function GuideAction2382:ctor(guide)
    GuideAction2382.super.ctor(self)

    self.info = "点击“酒馆”按钮"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "treasureBtn"

end

function GuideAction2382:onEnter(guide)
    GuideAction2382.super.onEnter(self, guide)
end

return GuideAction2382