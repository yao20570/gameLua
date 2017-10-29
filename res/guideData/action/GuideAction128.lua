local GuideAction128 = class("GuideAction128", AreaClickAction)

function GuideAction128:ctor()
    GuideAction128.super.ctor(self)
    
    self.info = "带领新部队，再攻下新的城池吧"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction128:onEnter(guide)
    GuideAction128.super.onEnter(self, guide)
end

return GuideAction128