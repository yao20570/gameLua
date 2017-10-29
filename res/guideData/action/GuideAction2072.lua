local GuideAction2072 = class( "GuideAction101", AreaClickAction)
function GuideAction2072:ctor()
   GuideAction2072.super.ctor(self)

  self.info = "一键装备，战力快速提升"
  self.moduleName = ModuleName.EquipModule
  self.panelName = "EquipMainPanelNewPanel"
  self.widgetName = "yijianBtn"
end

function GuideAction2072:onEnter(guide)
   GuideAction2072.super.onEnter(self, guide)
   local panel = guide:getPanel(ModuleName.EquipModule,"EquipMainPanelNewPanel")
   panel:show(2)
end

return GuideAction2072
