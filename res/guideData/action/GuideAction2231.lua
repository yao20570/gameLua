local GuideAction2231 = class( "GuideAction101", AreaClickAction)
function GuideAction2231:ctor()
   GuideAction2231.super.ctor(self)

  self.info = "这里是同盟"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPanel17_14"
end

function GuideAction2231:onEnter(guide)
   GuideAction2231.super.onEnter(self, guide)
end

return GuideAction2231
