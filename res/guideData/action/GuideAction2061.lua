local GuideAction2061 = class( "GuideAction101", AreaClickAction)
function GuideAction2061:ctor()
    GuideAction2061.super.ctor(self)

    self.info = "打开活动荟萃"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "activBtn"
end

function GuideAction2061:onEnter(guide)
    GuideAction2061.super.onEnter(self, guide)
    guide:sendNotification(AppEvent.GUIDE_NOTICE, AppEvent.ACTIVITE_SHOW_BTN)
end

return GuideAction2061
