local GuideAction136 = class("GuideAction136", AreaClickAction)

function GuideAction136:ctor()
    GuideAction136.super.ctor(self)
    
    self.info = "黄巾军又来偷袭，赶紧反击"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction136:onEnter(guide)
    GuideAction136.super.onEnter(self, guide)
    
    self._guide:hideModule(ModuleName.TaskModule)
end

return GuideAction136