local GuideAction2374 = class( "GuideAction101", AreaClickAction)
function GuideAction2374:ctor(guide)
    GuideAction2374.super.ctor(self)

    self.info = "点击“命中诀窍”升级"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoSkillPanel"
    self.widgetName = "item1"

end

function GuideAction2374:onEnter(guide)
    GuideAction2374.super.onEnter(self, guide)
end

return GuideAction2374