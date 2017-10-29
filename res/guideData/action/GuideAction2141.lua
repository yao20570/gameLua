local GuideAction2141 = class( "GuideAction101", AreaClickAction)
function GuideAction2141:ctor()
   GuideAction2141.super.ctor(self)

  self.info = "武将培养"
  self.moduleName = ModuleName.ToolbarModule
  self.panelName = "ToolbarPanel"
  self.widgetName = "btnItem8"
end

function GuideAction2141:onEnter(guide)
   GuideAction2141.super.onEnter(self, guide)
   guide:sendNotification(AppEvent.GUIDE_NOTICE, AppEvent.TOOLBAR_SHOW_BTN)
end

return GuideAction2141
