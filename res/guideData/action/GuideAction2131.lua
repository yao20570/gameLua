local GuideAction2131 = class( "GuideAction101", AreaClickAction)
function GuideAction2131:ctor()
   GuideAction2131.super.ctor(self)

  self.info = "打开酒馆界面"
  self.moduleName = ModuleName.ToolbarModule
  self.panelName = "ToolbarPanel"
  self.widgetName = "treasureBtn"
end

function GuideAction2131:onEnter(guide)
   GuideAction2131.super.onEnter(self, guide)
   guide:sendNotification(AppEvent.GUIDE_NOTICE, AppEvent.ACTIVITE_SHOW_BTN)
end

return GuideAction2131
