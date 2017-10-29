local GuideAction2031 = class( "GuideAction101", DialogueAction)
function GuideAction2031:ctor()
   GuideAction2031.super.ctor(self)

  self.info = "建造资源，屯兵积粮"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPos8"
end

function GuideAction2031:onEnter(guide)
   GuideAction2031.super.onEnter(self, guide)
end

return GuideAction2031
