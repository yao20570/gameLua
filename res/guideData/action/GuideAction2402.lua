local GuideAction2402 = class( "GuideAction101", AreaClickAction)
function GuideAction2402:ctor(guide)
    GuideAction2402.super.ctor(self)

    self.info = "点击“战役”按钮"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1"
    

end

function GuideAction2402:onEnter(guide)
    GuideAction2402.super.onEnter(self, guide)
end

return GuideAction2402