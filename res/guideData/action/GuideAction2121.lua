local GuideAction2121 = class( "GuideAction101", AreaClickAction)
function GuideAction2121:ctor()
   GuideAction2121.super.ctor(self)

  self.info = "打开太学院"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPanel8_12"
end

function GuideAction2121:onEnter(guide)
   GuideAction2121.super.onEnter(self, guide)
end

return GuideAction2121
