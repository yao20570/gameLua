local GuideAction124 = class("GuideAction124", AreaClickAction)

function GuideAction124:ctor()
    GuideAction124.super.ctor(self)
    
    self.info = "我们先征招步兵，提升战力"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackProductPanel"
    self.widgetName = "sureBtn"
    self.isShowArrow = false
end

function GuideAction124:onEnter(guide)
    GuideAction124.super.onEnter(self, guide)
end

return GuideAction124