local GuideAction429 = class("GuideAction429", AreaClickAction)

function GuideAction429:ctor()
    GuideAction429.super.ctor(self)
    
    self.info = "前往武将阵容"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem8" --点击阵容按钮
end

function GuideAction429:onEnter(guide)
    GuideAction429.super.onEnter(self, guide)
    
end

return GuideAction429