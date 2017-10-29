local GuideAction2102 = class( "GuideAction101", AreaClickAction)
function GuideAction2102:ctor()
   GuideAction2102.super.ctor(self)

  self.info = "升统率、出战更多士兵，战斗升得快"
  self.moduleName = ModuleName.PersonInfoModule
  self.panelName = "PersonInfoDetailsPanel"
  self.widgetName = "btn3"
end

function GuideAction2102:onEnter(guide)
   GuideAction2102.super.onEnter(self, guide)
end

return GuideAction2102
