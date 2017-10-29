local GuideAction434e = class("GuideAction434e", AreaClickAction)

function GuideAction434e:ctor()
    GuideAction434e.super.ctor(self)
    
    self.info = "前往战役"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1" --战役按钮
    
    self.isShowArrow = false

    self.callbackArg = true --直接跳转到第一章的步骤
end

function GuideAction434e:onEnter(guide)
    GuideAction434e.super.onEnter(self, guide)
end

return GuideAction434e