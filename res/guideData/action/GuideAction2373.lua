local GuideAction2373 = class( "GuideAction101", AreaClickAction)
function GuideAction2373:ctor(guide)
    GuideAction2373.super.ctor(self)

    self.info = "点击战法按钮"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoPanel"
    self.widgetName = "tabBtn2"

end

function GuideAction2373:onEnter(guide)
    GuideAction2373.super.onEnter(self, guide)
end

return GuideAction2373