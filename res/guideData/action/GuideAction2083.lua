local GuideAction2083 = class( "GuideAction101", AreaClickAction)
function GuideAction2083:ctor()
   GuideAction2083.super.ctor(self)

  self.info = "强化"
  self.moduleName = ModuleName.EquipModule
  self.panelName = "EquipMainPanelNewPanel"
  self.widgetName = "upBtn"
end

function GuideAction2083:onEnter(guide)
   GuideAction2083.super.onEnter(self, guide)
end

return GuideAction2083
