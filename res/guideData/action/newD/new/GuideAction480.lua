local GuideAction481 = class("GuideAction481", AreaClickAction)

function GuideAction481:ctor()
    GuideAction481.super.ctor(self)
    
    self.info = "点击小宴9连抽"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "treasureBtn" --点击点击酒馆

    self.delayTimePre = 1
end

function GuideAction481:onEnter(guide)
    GuideAction481.super.onEnter(self, guide)
    
end

return GuideAction481