local GuideAction329 = class("GuideAction329", AreaClickAction)

function GuideAction329:ctor()
    GuideAction329.super.ctor(self)
    
    self.info = "前往武将阵容"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem8" --点击阵容按钮
end

function GuideAction329:onEnter(guide)
    GuideAction329.super.onEnter(self, guide)
    
end

return GuideAction329