local GuideAction2032 = class( "GuideAction101", AreaClickAction)
function GuideAction2032:ctor()
   GuideAction2032.super.ctor(self)

  self.info = "点击一个建筑"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPos8"
end

function GuideAction2032:onEnter(guide)
   GuideAction2032.super.onEnter(self, guide)
end

return GuideAction2032
