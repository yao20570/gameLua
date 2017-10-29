local GuideAction334 = class("GuideAction334", AreaClickAction)

function GuideAction334:ctor()
    GuideAction334.super.ctor(self)
    
    self.info = "前往战役"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1" --战役按钮
    
    self.isShowArrow = false
end

function GuideAction334:onEnter(guide)
    GuideAction334.super.onEnter(self, guide)
end

return GuideAction334