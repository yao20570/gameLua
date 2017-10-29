local GuideAction2071 = class( "GuideAction101", AreaClickAction)
function GuideAction2071:ctor()
	GuideAction2071.super.ctor(self)

	self.info = "招募到了武将，记得来这里上阵"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem8"
end

function GuideAction2071:onEnter(guide)
    GuideAction2071.super.onEnter(self, guide)
    guide:sendNotification(AppEvent.GUIDE_NOTICE, AppEvent.TOOLBAR_SHOW_BTN)

end

return GuideAction2071
