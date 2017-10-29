local GuideAction2392 = class( "GuideAction101", AreaClickAction)
function GuideAction2392:ctor(guide)
    GuideAction2392.super.ctor(self)

    self.info = "点击“战役”按钮"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1"

end

function GuideAction2392:onEnter(guide)
    GuideAction2392.super.onEnter(self, guide)
end

return GuideAction2392