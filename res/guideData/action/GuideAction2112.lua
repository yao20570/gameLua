local GuideAction2112 = class( "GuideAction101", AreaClickAction)
function GuideAction2112:ctor()
   GuideAction2112.super.ctor(self)

  self.info = "提升全军的战法"
  self.moduleName = ModuleName.PersonInfoModule
  self.panelName = "PersonInfoPanel"
  self.widgetName = "tabBtn2"
end

function GuideAction2112:onEnter(guide)
   GuideAction2112.super.onEnter(self, guide)
end

return GuideAction2112
