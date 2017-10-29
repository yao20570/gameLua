local GuideAction306 = class("GuideAction306", AreaClickAction)

function GuideAction306:ctor()
    GuideAction306.super.ctor(self)
    
    self.info = "前往招兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "tabBtn2"
    self.isShowArrow = false
end

function GuideAction306:onEnter(guide)
    GuideAction306.super.onEnter(self, guide)
end

return GuideAction306