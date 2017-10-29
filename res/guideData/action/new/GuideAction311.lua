local GuideAction311 = class("GuideAction311", AreaClickAction)

function GuideAction311:ctor()
    GuideAction311.super.ctor(self)
    
    self.info = "离开兵营"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "closeBtn"
    self.isShowArrow = false
end

function GuideAction311:onEnter(guide)
    GuideAction311.super.onEnter(self, guide)
end

return GuideAction311