local GuideAction2211 = class( "GuideAction101", AreaClickAction)
function GuideAction2211:ctor()
   GuideAction2211.super.ctor(self)

  self.info = "到世界采集资源"
  self.moduleName = ModuleName.ToolbarModule
  self.panelName = "ToolbarPanel"
  self.widgetName = "sceneBtn"
end

function GuideAction2211:onEnter(guide)
   GuideAction2211.super.onEnter(self, guide)
end

return GuideAction2211
