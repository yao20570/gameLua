local GuideAction2201 = class( "GuideAction101", AreaClickAction)
function GuideAction2201:ctor()
   GuideAction2201.super.ctor(self)

  self.info = "前往世界征战"
  self.moduleName = ModuleName.ToolbarModule
  self.panelName = "ToolbarPanel"
  self.widgetName = "sceneBtn"
end

function GuideAction2201:onEnter(guide)
   GuideAction2201.super.onEnter(self, guide)
end

return GuideAction2201
