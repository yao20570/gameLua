local GuideAction308 = class("GuideAction308", AreaClickAction)

function GuideAction308:ctor()
    GuideAction308.super.ctor(self)
    
    self.info = "征召100只步兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackProductPanel"
    self.widgetName = "sureBtn"
    self.isShowArrow = false
end

function GuideAction308:onEnter(guide)
    GuideAction308.super.onEnter(self, guide)
end

return GuideAction308