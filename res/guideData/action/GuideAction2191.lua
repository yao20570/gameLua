local GuideAction2191 = class( "GuideAction101", AreaClickAction)
function GuideAction2191:ctor()
   GuideAction2191.super.ctor(self)

  self.info = "这里进入战役"
  self.moduleName = ModuleName.ToolbarModule
  self.panelName = "ToolbarPanel"
  self.widgetName = "btnItem1"
end

function GuideAction2191:onEnter(guide)
   GuideAction2191.super.onEnter(self, guide)
   guide:sendNotification(AppEvent.GUIDE_NOTICE, AppEvent.TOOLBAR_SHOW_BTN)
end

return GuideAction2191
