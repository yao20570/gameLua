local GuideAction2412 = class( "GuideAction101", AreaClickAction)
function GuideAction2412:ctor(guide)
    GuideAction2412.super.ctor(self)

  	self.info = "点击演武场"
  	self.moduleName = ModuleName.MainSceneModule
  	self.panelName = "MainScenePanel"
  	self.widgetName = "buildingPanel16_13"

end

function GuideAction2412:onEnter(guide)
    GuideAction2412.super.onEnter(self, guide)
end

return GuideAction2412