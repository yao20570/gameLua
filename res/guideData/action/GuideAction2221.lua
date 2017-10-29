local GuideAction2221 = class( "GuideAction101", AreaClickAction)
function GuideAction2221:ctor()
   GuideAction2221.super.ctor(self)

  self.info = "来这里做任务"
  self.moduleName = ModuleName.ToolbarModule
  self.panelName = "ToolbarPanel"
  self.widgetName = "btnItem3"
end

function GuideAction2221:onEnter(guide)
   GuideAction2221.super.onEnter(self, guide)
   guide:sendNotification(AppEvent.GUIDE_NOTICE, AppEvent.TOOLBAR_SHOW_BTN)
end

return GuideAction2221
