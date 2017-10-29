local GuideAction434 = class("GuideAction434", AreaClickAction)

function GuideAction434:ctor()
    GuideAction434.super.ctor(self)
    
    self.info = "前往战役"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1" --战役按钮
    
    self.isShowArrow = false
end

function GuideAction434:onEnter(guide)
    GuideAction434.super.onEnter(self, guide)
end

return GuideAction434