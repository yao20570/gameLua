local GuideAction2051 = class( "GuideAction101", AreaClickAction)
function GuideAction2051:ctor()
   GuideAction2051.super.ctor(self)

  self.info = "打开活动荟萃"
  self.moduleName = ModuleName.ToolbarModule
  self.panelName = "ToolbarPanel"
  self.widgetName = "activBtn"
end

function GuideAction2051:onEnter(guide)
   GuideAction2051.super.onEnter(self, guide)
   guide:sendNotification(AppEvent.GUIDE_NOTICE, AppEvent.ACTIVITE_SHOW_BTN)
end

return GuideAction2051
