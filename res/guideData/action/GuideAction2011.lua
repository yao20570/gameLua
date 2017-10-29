local GuideAction2011 = class( "GuideAction101", AreaClickAction)
function GuideAction2011:ctor()
   GuideAction2011.super.ctor(self)

  self.info = "官邸是其他建筑的建造前提"
  self.moduleName = ModuleName.MainSceneModule
  self.panelName = "MainScenePanel"
  self.widgetName = "buildingPanel1_1"
end

function GuideAction2011:onEnter(guide)
   GuideAction2011.super.onEnter(self, guide)
end

return GuideAction2011
