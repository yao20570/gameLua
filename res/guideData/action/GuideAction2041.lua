local GuideAction2041 = class( "GuideAction101", AreaClickAction)
function GuideAction2041:ctor()
   GuideAction2041.super.ctor(self)

  self.info = "科技越高，战力越强"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPanel8_12"
end

function GuideAction2041:onEnter(guide)
   GuideAction2041.super.onEnter(self, guide)
end

return GuideAction2041
