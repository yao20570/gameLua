local GuideAction2081 = class( "GuideAction101", AreaClickAction)
function GuideAction2081:ctor()
   GuideAction2081.super.ctor(self)

  self.info = "招募了武将，来这里培养"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPanel13_6"
end

function GuideAction2081:onEnter(guide)
   GuideAction2081.super.onEnter(self, guide)
end

return GuideAction2081
