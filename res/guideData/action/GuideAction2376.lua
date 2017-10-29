local GuideAction2376 = class( "GuideAction101", AreaClickAction)
function GuideAction2376:ctor(guide)
    GuideAction2376.super.ctor(self)

    self.info = "离开"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoPanel"
    self.widgetName = "closeBtn"

end

function GuideAction2376:onEnter(guide)
    GuideAction2376.super.onEnter(self, guide)
end

return GuideAction2376