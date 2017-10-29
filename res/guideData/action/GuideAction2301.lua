local GuideAction2301 = class( "GuideAction101", AreaClickAction)
function GuideAction2301:ctor()
   GuideAction2301.super.ctor(self)

  self.info = "招得武将，来这里升级"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPanel13_6"
end

function GuideAction2301:onEnter(guide)
   GuideAction2301.super.onEnter(self, guide)
end

return GuideAction2301
