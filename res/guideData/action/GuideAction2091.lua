local GuideAction2091 = class( "GuideAction101", AreaClickAction)
function GuideAction2091:ctor()
   GuideAction2091.super.ctor(self)

  self.info = "在兵营招募士兵"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPanel9_2"
end

function GuideAction2091:onEnter(guide)
   GuideAction2091.super.onEnter(self, guide)
end

return GuideAction2091
