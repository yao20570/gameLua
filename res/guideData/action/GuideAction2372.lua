local GuideAction2372 = class( "GuideAction101", AreaClickAction)
function GuideAction2372:ctor(guide)
    GuideAction2372.super.ctor(self)

    self.info = "点击头像"
    self.moduleName = ModuleName.RoleInfoModule
    self.panelName = "RoleInfoPanel"
    self.widgetName = "headBtn"
    self.isShowArrow = false

end

function GuideAction2372:onEnter(guide)
    GuideAction2372.super.onEnter(self, guide)
end

return GuideAction2372